import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'detail.dart';

class Multan extends StatefulWidget {
  const Multan({super.key});

  @override
  State<Multan> createState() => _MultanState();
}

class _MultanState extends State<Multan> with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
    ),
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.orange[100],
      end: Colors.transparent,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
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
          primary: const Color(0xFFE67E22), // Orange shade
          secondary: const Color(0xFF2ECC71), // Green shade
          surface: Colors.white,
          background: const Color(0xFFF9F9F9),
          error: const Color(0xFFE74C3C),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF333333),
          onBackground: const Color(0xFF333333),
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        cardTheme: CardTheme(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFE67E22),
          elevation: 0,
          titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          headlineSmall: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
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
                stream: FirebaseFirestore.instance.collection('multan').snapshots(),
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
                      // Enhanced Header Sliver with Multan theme
                      SliverAppBar(
                        expandedHeight: 300,
                        pinned: true,
                        floating: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: 'multan-hero',
                                child: Image.asset(
                                  "../assets/images/multan.jpg",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      const Color(0xFFE67E22).withOpacity(0.8),
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
                              offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
                              child: Text(
                                "City of Saints",
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(blurRadius: 8, color: Colors.black45),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          centerTitle: true,
                          titlePadding: const EdgeInsets.only(bottom: 16),
                          collapseMode: CollapseMode.parallax,
                        ),
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.search, size: 28),
                            onPressed: () {},
                          ),
                        ],
                      ),

                      // Content Sliver with animations
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            var data = attractions[index].data() as Map<String, dynamic>;
                            
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
                              child: _buildAttractionCard(context, data, attractions[index].id, index),
                            );
                          },
                          childCount: attractions.length,
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
          CircularProgressIndicator(
            color: colorScheme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            "Discovering Multan...",
            style: TextStyle(
              color: colorScheme.onBackground,
              fontSize: 16,
            ),
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
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.error,
            size: 60,
          ),
          const SizedBox(height: 20),
          Text(
            "Oops! Something went wrong",
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Please try again later",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => setState(() {}),
            child: Text(
              "Retry",
              style: TextStyle(color: colorScheme.onPrimary),
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
            size: 60,
          ),
          const SizedBox(height: 20),
          Text(
            "No attractions found",
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Check back later for updates",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionCard(BuildContext context, Map<String, dynamic> data, String documentId, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder: (_, __, ___) => Detail(
                listing: data,
                collection: 'multan',
                documentId: documentId,
              ),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastOutSlowIn,
                  )),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Image with gradient overlay
              Hero(
                tag: 'attraction-${data['name']}',
                child: AspectRatio(
                  aspectRatio: 16/9,
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
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: colorScheme.primary,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.surfaceVariant,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: 50,
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
                              Colors.black.withOpacity(0.6),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with animated underline
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 800),
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
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  height: 2,
                                  width: 100 * value,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Location with animated icon
                      Row(
                        children: [
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 500),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(20 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              data['location'] ?? 'Location not available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Rating and CTA with staggered animation
                      Row(
                        children: [
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 600),
                            tween: Tween<double>(begin: 0, end: 1),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber[700],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    double.tryParse(data['rating'].toString())?.toStringAsFixed(1) ?? '0.0',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const Spacer(),
                          
                          TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween<double>(begin: 0, end: 1),
                            curve: Curves.fastOutSlowIn,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(20 * (1 - value), 0),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Explore',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
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
                top: 16,
                right: 16,
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 700),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: FloatingActionButton.small(
                    heroTag: 'fav-$index',
                    backgroundColor: Colors.white,
                    onPressed: () {},
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: colorScheme.primary,
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