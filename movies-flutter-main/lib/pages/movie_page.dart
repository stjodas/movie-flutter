import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/models/movie_model.dart';
import '../core/constants.dart';
import 'movie_detail_page.dart';
import '../widgets/centered_message.dart';
import '../widgets/centered_progress.dart';
import '../widgets/movie_card.dart';
import '../controllers/movie_controller.dart';

class MoviePage extends StatefulWidget {
  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final _controller = MovieController();
  static const _pageSize = 20;
  final PagingController<int, MovieModel> _pagingController =
      PagingController(firstPageKey: 1);
  int lastPage = 1;

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _initialize();
  }

  Future<void> _fetchPage(int pageKey) async {
    final newItems = await _controller.fetchAllMovies(page: pageKey);

    final isLastPage =
        newItems.fold((l) => null, (r) => r.movies.length) < _pageSize;
    if (isLastPage) {
      _pagingController.appendLastPage(
          newItems.fold((error) => null, (movies) => movies.movies));
    } else {
      final nextPageKey = pageKey + 1;
      print(pageKey);
      _pagingController.appendPage(
          newItems.fold((error) => null, (movies) => movies.movies),
          nextPageKey);
    }
  }

  _changeGrid() {
    setState(() {
      _controller.changeGridSize();
    });
  }

  _initialize() async {
    setState(() {
      _controller.loading = true;
    });

    setState(() {
      _controller.loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildMovieGrid(),
    );
  }

  _buildAppBar() {
    return AppBar(
      title: Text(kAppName),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _initialize,
        ),
        IconButton(
          icon: Icon(Icons.grid_view),
          onPressed: _changeGrid,
        )
      ],
    );
  }

  _buildMovieGrid() {
    if (_controller.loading) {
      return CenteredProgress();
    }

    if (_controller.movieError != null) {
      return CenteredMessage(message: _controller.movieError.message);
    }

    return PagedGridView<int, MovieModel>(
      pagingController: _pagingController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 100 / 150,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        crossAxisCount: _controller.gridSize,
      ),
      builderDelegate: PagedChildBuilderDelegate<MovieModel>(
        itemBuilder: (context, item, index) => _buildMovieCard(context, index),
      ),
    );
  }

  Widget _buildMovieCard(context, index) {
    final movie = _controller.movies[index];
    return MovieCard(
      posterPath: movie.posterPath,
      onTap: () => _openDetailPage(movie.id),
    );
  }

  _openDetailPage(movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(movieId),
      ),
    );
  }
}
