import 'package:flutter/material.dart';
import 'package:flutter_pokemon/data/response/pokemon_detail_response.dart';
import 'package:flutter_pokemon/data/services/pokemon_service.dart';
import 'package:flutter_pokemon/utils/pokemon_card_colors.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({required this.pokemonId, super.key});

  final int pokemonId;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  final PokemonService pokemonService = PokemonService();
  PokemonDetailResponse? _pokemon;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPokemon);
  }

  Future<void> _loadPokemon() async {
    try {
      final result = await pokemonService.fetchPokemonDetail(widget.pokemonId);
      if (!mounted) return;
      setState(() {
        _pokemon = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load Pokemon details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = _pokemon;

    Widget body;
    if (_isLoading) {
      body = _PokemonDetailLoading(pokemonId: widget.pokemonId);
    } else if (pokemon == null) {
      body = Center(
        child: Text(
          _errorMessage ?? 'Pokemon not found',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    } else {
      body = _PokemonDetailBody(pokemon: pokemon);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Text('Detail Pokemon - ${pokemon?.name ?? 'Loading...'}'),
      ),
      body: body,
    );
  }
}

class _PokemonDetailBody extends StatelessWidget {
  const _PokemonDetailBody({required this.pokemon});

  final PokemonDetailResponse pokemon;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(pokemon: pokemon),
          const SizedBox(height: 28),
          Text(
            'About',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _AboutCard(pokemon: pokemon),
        ],
      ),
    );
  }
}

class _PokemonDetailLoading extends StatelessWidget {
  const _PokemonDetailLoading({required this.pokemonId});

  final int pokemonId;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrlFor(pokemonId);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'pokemon-image-$pokemonId',
            child: Image.network(
              imageUrl,
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.catching_pokemon,
                color: Colors.black26,
                size: 120,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.pokemon});

  final PokemonDetailResponse pokemon;

  @override
  Widget build(BuildContext context) {
    final cardColor = cardColorForName(pokemon.name);
    final formattedNumber = _formattedNumber(pokemon.id);
    final heroTag = 'pokemon-image-${pokemon.id}';
    final imageUrl = _imageUrlFor(pokemon.id);
    final typeLabels = pokemon.types
        .map((type) => _capitalize(type.type.name))
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [cardColor.withOpacity(0.9), cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pokemon.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedNumber,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: typeLabels
                .map((t) => _PokemonTypeChip(label: t))
                .toList(),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.center,
            child: Hero(
              tag: heroTag,
              child: Image.network(
                imageUrl,
                height: 170,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.catching_pokemon,
                  color: Colors.white54,
                  size: 120,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.pokemon});

  final PokemonDetailResponse pokemon;

  @override
  Widget build(BuildContext context) {
    final heightMeters = pokemon.height / 10;
    final weightKg = pokemon.weight / 10;
    final typeText = pokemon.types.isEmpty
        ? 'Unknown'
        : pokemon.types.map((t) => _capitalize(t.type.name)).join(', ');
    final description = _descriptionForPokemon(pokemon, typeText);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'ID', value: _formattedNumber(pokemon.id)),
          _InfoRow(label: 'Types', value: typeText),
          _InfoRow(
            label: 'Height',
            value: '${heightMeters.toStringAsFixed(1)} m',
          ),
          _InfoRow(label: 'Weight', value: '${weightKg.toStringAsFixed(1)} kg'),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PokemonTypeChip extends StatelessWidget {
  const _PokemonTypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _formattedNumber(int id) => '#${id.toString().padLeft(3, '0')}';

String _imageUrlFor(int id) =>
    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

String _descriptionForPokemon(PokemonDetailResponse pokemon, String typeText) {
  final displayName = _capitalize(pokemon.name);
  final height = (pokemon.height / 10).toStringAsFixed(1);
  final weight = (pokemon.weight / 10).toStringAsFixed(1);
  return '$displayName is a $typeText Pokemon with a height of $height m and a weight of $weight kg.';
}
