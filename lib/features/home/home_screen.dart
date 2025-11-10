import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../core/utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentBottomIndex = 0;
  final PageController _sliderController = PageController();
  int _currentSliderPage = 0;

  @override
  void dispose() {
    _sliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حقيبة المؤمن+'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Global search
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    if (_currentBottomIndex != 0) {
      return _buildBottomNavPages();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingCard(),
          const SizedBox(height: 16),
          _buildSlider(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'الأقسام',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeaturesGrid(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    final greeting = AppUtils.getGreeting();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'السلام عليكم ورحمة الله وبركاته',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.wb_sunny_outlined,
            size: 48,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    final adhkarAsync = ref.watch(adhkarListProvider);

    return SizedBox(
      height: 180,
      child: adhkarAsync.when(
        data: (adhkar) {
          if (adhkar.isEmpty) return const SizedBox.shrink();
          
          final displayAdhkar = adhkar.take(3).toList();
          
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _sliderController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentSliderPage = index;
                    });
                  },
                  itemCount: displayAdhkar.length,
                  itemBuilder: (context, index) {
                    final dhikr = displayAdhkar[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ذكر اليوم',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Center(
                              child: Text(
                                dhikr.text,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: 18,
                                  height: 1.8,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '(${dhikr.repeatCount} مرة)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  displayAdhkar.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentSliderPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentSliderPage == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {'title': 'القرآن الكريم', 'icon': Icons.book, 'route': '/quran'},
      {'title': 'الأحاديث', 'icon': Icons.format_quote, 'route': '/hadith'},
      {'title': 'مواقيت الصلاة', 'icon': Icons.access_time, 'route': '/prayer'},
      {'title': 'الأدعية', 'icon': Icons.favorite, 'route': '/duas'},
      {'title': 'المسبحة', 'icon': Icons.circle_outlined, 'route': '/tasbih'},
      {'title': 'التقويم', 'icon': Icons.calendar_today, 'route': '/calendar'},
      {'title': 'القبلة', 'icon': Icons.explore, 'route': '/qibla'},
      {'title': 'الأذكار', 'icon': Icons.auto_stories, 'route': '/adhkar'},
      {'title': 'الإعدادات', 'icon': Icons.settings, 'route': '/settings'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return _buildFeatureCard(
            title: feature['title'] as String,
            icon: feature['icon'] as IconData,
            onTap: () => context.push(feature['route'] as String),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavPages() {
    switch (_currentBottomIndex) {
      case 1:
        return _buildPlaceholder('الأذكار');
      case 2:
        return _buildPlaceholder('التقويم');
      case 3:
        return _buildPlaceholder('القبلة');
      case 4:
        return _buildPlaceholder('المزيد');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentBottomIndex,
      onTap: (index) {
        setState(() {
          _currentBottomIndex = index;
        });
        
        // Navigate to specific routes
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.push('/adhkar');
            break;
          case 2:
            context.push('/calendar');
            break;
          case 3:
            context.push('/qibla');
            break;
          case 4:
            context.push('/settings');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_stories),
          label: 'الأذكار',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'التقويم',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'القبلة',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'المزيد',
        ),
      ],
    );
  }
}
