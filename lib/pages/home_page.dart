import 'package:flutter/material.dart';
import 'package:flutter_pokemon/data/response/pokemon_list_response.dart';
import 'package:flutter_pokemon/data/services/pokemon_service_dio.dart';
import 'package:flutter_pokemon/pages/detail_page.dart';
import 'package:flutter_pokemon/state/remote_state.dart';
import 'package:flutter_pokemon/utils/pokemon_card_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RemoteState<PokemonListResponse> state = const RemoteStateLoading();
  final PokemonServiceDio pokemonService = PokemonServiceDio();

  int offset = 0;
  final int limit = 10;
  bool isLoadingMore = false;

  List<Result> pokemonList = [];

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadPokemons();

    scrollController.addListener(() {
      if (!isLoadingMore &&
          scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  // LOAD PERTAMA
  Future<void> loadPokemons() async {
    final result = await pokemonService.fetchPokemons(
      offset: offset,
      limit: limit,
    );

    if (!mounted) return;

    if (result is RemoteStateSuccess<PokemonListResponse>) {
      pokemonList = result.data.results;
    }

    setState(() => state = result);
  }

  // LOAD BERIKUTNYA SAAT SCROLL
  Future<void> loadMore() async {
    if (isLoadingMore) return;

    setState(() => isLoadingMore = true);

    offset += limit;

    final result = await pokemonService.fetchPokemons(
      offset: offset,
      limit: limit,
    );

    if (result is RemoteStateSuccess<PokemonListResponse>) {
      final newData = result.data.results;

      if (newData.isNotEmpty) {
        setState(() {
          pokemonList.addAll(newData);
        });
      }
    }

    setState(() => isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(theme: theme),
              const SizedBox(height: 24),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // LOADING
    if (state is RemoteStateLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ERROR
    if (state is RemoteStateError) {
      final message = (state as RemoteStateError).message;
      return Center(child: Text("Error: $message"));
    }

    // SUCCESS
    if (state is RemoteStateSuccess<PokemonListResponse>) {
      return GridView.builder(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.9,
        ),
        itemCount: pokemonList.length + 1,
        itemBuilder: (context, index) {
          // Loading indicator di bawah list
          if (index == pokemonList.length) {
            return isLoadingMore
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink();
          }

          final pokemon = pokemonList[index];
          return PokemonCard(pokemon: pokemon);
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Pokemon',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What Pokemon are you looking for?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PokemonCard extends StatelessWidget {
  const PokemonCard({required this.pokemon, super.key});

  final Result pokemon;

  @override
  Widget build(BuildContext context) {
    final cardColor = cardColorForName(pokemon.name);
    final pokemonId = _pokemonIdFromUrl(pokemon.url);
    final numberLabel = pokemonId > 0
        ? '#${pokemonId.toString().padLeft(3, '0')}'
        : '';
    final imageUrl = pokemonId > 0
        ? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png'
        : null;
    final heroTag = 'pokemon-image-${pokemonId > 0 ? pokemonId : pokemon.name}';

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: pokemonId > 0
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PokemonDetailPage(pokemonId: pokemonId),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [cardColor.withValues(alpha: 0.9), cardColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          pokemon.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Text(
                        numberLabel,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Spacer(),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SizedBox(
                height: 110,
                child: Hero(
                  tag: heroTag,
                  child: imageUrl == null
                      ? const Icon(
                          Icons.catching_pokemon,
                          color: Colors.white54,
                          size: 72,
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.catching_pokemon,
                            color: Colors.white54,
                            size: 72,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _pokemonIdFromUrl(String url) {
    final match = RegExp(r'/pokemon/(\d+)/?').firstMatch(url);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '') ?? 0;
    }
    final sanitized = url.split('/')..removeWhere((segment) => segment.isEmpty);
    if (sanitized.isNotEmpty) {
      return int.tryParse(sanitized.last) ?? 0;
    }
    return 0;
  }
}
