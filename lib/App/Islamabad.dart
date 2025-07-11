import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'detail.dart';

class IslamabadPage extends StatefulWidget {
  const IslamabadPage({super.key});

  @override
  State<IslamabadPage> createState() => _IslamabadPageState();
}

class _IslamabadPageState extends State<IslamabadPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.purple[100],
      end: Colors.transparent,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF8A2BE2), // Purple
          secondary: const Color(0xFF20B2AA), // Light sea green
          surface: Colors.white,
          background: const Color(0xFFF8F8FF), // Ghost white
          error: const Color(0xFFFF6B6B),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF2D3436),
          onBackground: const Color(0xFF2D3436),
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF8A2BE2),
          elevation: 0,
          titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          headlineSmall: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FF),
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _colorAnimation.value ?? Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Islamabad')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState(colorScheme);
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(theme, colorScheme);
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(theme, colorScheme);
                  }

                  var attractions = snapshot.data!.docs;

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Enhanced Parallax Header
                      SliverAppBar(
                        expandedHeight: 350,
                        pinned: true,
                        floating: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: 'islamabad-hero',
                                child: Image.asset(
                                  "../assets/images/FaisalMosque.jpg",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      const Color(0xFF8A2BE2).withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.1, 0.5],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: AnimatedOpacity(
                            opacity: _fadeAnimation.value,
                            duration: const Duration(milliseconds: 500),
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                15 * (1 - _fadeAnimation.value),
                              ),
                              child: Text(
                                "Islamabad Wonders",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 28,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          centerTitle: true,
                          titlePadding: const EdgeInsets.only(bottom: 20),
                          collapseMode: CollapseMode.parallax,
                        ),
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.search, size: 30),
                            onPressed: () {},
                          ),
                        ],
                      ),

                      // Content Sliver with animated cards
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            var data =
                                attractions[index].data()
                                    as Map<String, dynamic>;

                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return SlideTransition(
                                  position: _slideAnimation,
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: child,
                                    ),
                                  ),
                                );
                              },
                              child: _buildAttractionCard(
                                context,
                                data,
                                attractions[index].id,
                                index,
                              ),
                            );
                          }, childCount: attractions.length),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 4),
          const SizedBox(height: 20),
          Text(
            "Discovering Islamabad...",
            style: TextStyle(color: colorScheme.onBackground, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 70),
          const SizedBox(height: 20),
          Text(
            "Failed to load data",
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Please check your connection and try again",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            onPressed: () => setState(() {}),
            child: Text(
              "Retry",
              style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off_rounded,
            color: colorScheme.onSurface.withOpacity(0.5),
            size: 70,
          ),
          const SizedBox(height: 20),
          Text(
            "No attractions available",
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "We'll add more places soon!",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionCard(
    BuildContext context,
    Map<String, dynamic> data,
    String documentId,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rating = double.tryParse(data['rating'].toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 900),
              pageBuilder:
                  (_, __, ___) => Detail(
                    listing: data,
                    collection: 'Islamabad',
                    documentId: documentId,
                  ),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.fastOutSlowIn,
                    ),
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 6,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Image with gradient overlay
              Hero(
                tag: 'attraction-${data['name']}',
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        data['image_url'] ?? '',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              color: colorScheme.primary,
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: colorScheme.surfaceVariant,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  size: 60,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with animated underline
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 900),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Stack(
                            children: [
                              Text(
                                data['name'] ?? 'Unknown Place',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  height: 3,
                                  width: 120 * value,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Location with animated icon
                      Row(
                        children: [
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(25 * (1 - value), 0),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              data['location'] ?? 'Location not available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // Rating and CTA with staggered animation
                      Row(
                        children: [
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 700),
                            tween: Tween<double>(begin: 0, end: 1),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber[700],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 900),
                            tween: Tween<double>(begin: 0, end: 1),
                            curve: Curves.fastOutSlowIn,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(25 * (1 - value), 0),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Details',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Floating favorite button
              Positioned(
                top: 20,
                right: 20,
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: FloatingActionButton.small(
                    heroTag: 'fav-$index',
                    backgroundColor: Colors.white.withOpacity(0.9),
                    onPressed: () {},
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
