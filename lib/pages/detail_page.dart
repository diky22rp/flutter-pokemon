import 'package:flutter/material.dart';
import 'package:flutter_pokemon/data/response/pokemon_detail_response.dart';
import 'package:flutter_pokemon/data/services/pokemon_service_dio.dart';
import 'package:flutter_pokemon/state/remote_state.dart';
import 'package:flutter_pokemon/utils/pokemon_card_colors.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({required this.pokemonId, super.key});

  final int pokemonId;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  final PokemonServiceDio pokemonService = PokemonServiceDio();

  RemoteState<PokemonDetailResponse> state = const RemoteStateLoading();

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    final result = await pokemonService.fetchPokemonDetail(widget.pokemonId);

    if (!mounted) return;
    setState(() => state = result);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (state is RemoteStateLoading) {
      body = _PokemonDetailLoading(pokemonId: widget.pokemonId);
    } else if (state is RemoteStateError) {
      final msg = (state as RemoteStateError).message;

      body = Center(
        child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      );
    } else if (state is RemoteStateSuccess<PokemonDetailResponse>) {
      final pokemon = (state as RemoteStateSuccess<PokemonDetailResponse>).data;

      body = _PokemonDetailBody(pokemon: pokemon);
    } else {
      body = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text("Detail Pokémon"),
      ),
      body: body,
    );
  }
}

// ===================== LOADING VIEW ======================

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
            tag: "pokemon-image-$pokemonId",
            child: Image.network(
              imageUrl,
              height: 160,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.catching_pokemon,
                size: 120,
                color: Colors.black26,
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

// ===================== SUCCESS VIEW ======================

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
            "About",
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

// ===================== HERO CARD ======================

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.pokemon});

  final PokemonDetailResponse pokemon;

  @override
  Widget build(BuildContext context) {
    final cardColor = cardColorForName(pokemon.name);
    final numberLabel = _formattedNumber(pokemon.id);
    final heroTag = "pokemon-image-${pokemon.id}";
    final imageUrl = _imageUrlFor(pokemon.id);

    final typeLabels = pokemon.types
        .map((t) => _capitalize(t.type.name))
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
          // Name + ID
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
                      numberLabel,
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
                color: Colors.white,
                icon: const Icon(Icons.favorite_border),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Type Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: typeLabels
                .map((label) => _PokemonTypeChip(label: label))
                .toList(),
          ),

          const SizedBox(height: 24),

          // Artwork
          Align(
            alignment: Alignment.center,
            child: Hero(
              tag: heroTag,
              child: Image.network(
                imageUrl,
                height: 170,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.catching_pokemon,
                  size: 120,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== ABOUT CARD ======================

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.pokemon});

  final PokemonDetailResponse pokemon;

  @override
  Widget build(BuildContext context) {
    final height = (pokemon.height / 10).toStringAsFixed(1);
    final weight = (pokemon.weight / 10).toStringAsFixed(1);
    final types = pokemon.types.map((t) => _capitalize(t.type.name)).join(", ");

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            blurRadius: 25,
            color: Color(0x14000000),
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: "ID", value: _formattedNumber(pokemon.id)),
          _InfoRow(label: "Types", value: types),
          _InfoRow(label: "Height", value: "$height m"),
          _InfoRow(label: "Weight", value: "$weight kg"),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            "${_capitalize(pokemon.name)} is a $types Pokémon weighing $weight kg with a height of $height m.",
            style: const TextStyle(color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ===================== SHARED COMPONENTS ======================

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

// ===================== HELPERS ======================

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String _formattedNumber(int id) => "#${id.toString().padLeft(3, "0")}";

String _imageUrlFor(int id) =>
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png";
