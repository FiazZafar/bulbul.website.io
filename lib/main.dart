import 'package:bulbul_project/image_path.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFE8B86D),
        scaffoldBackgroundColor: const Color(0xFFFFFBF5),
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8B86D),
          primary: const Color(0xFFE8B86D),
          secondary: const Color(0xFF8B4513),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    'Home': GlobalKey(),
    'About': GlobalKey(),
    'Menu': GlobalKey(),
    'Reviews': GlobalKey(),
    'Contact': GlobalKey(),
  };

  void _scrollToSection(String section) {
    final key = _sectionKeys[section];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            AnimatedNavBar(onNavigate: _scrollToSection),
            HeroSection(key: _sectionKeys['Home']),
            AboutSection(key: _sectionKeys['About']),
            MenuSection(key: _sectionKeys['Menu']),
            ContactSection(key: _sectionKeys['Contact']),
            ReviewsSection(key: _sectionKeys['Reviews']),
            const FooterSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scrollToSection('Home'),
        backgroundColor: const Color(0xFFE8B86D),
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }
}

// ---------------------- ANIMATED NAVBAR ----------------------
class AnimatedNavBar extends StatefulWidget {
  final Function(String section) onNavigate;
  const AnimatedNavBar({super.key, required this.onNavigate});

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _hoveredItem = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 850;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: isMobile ? 20 : 60,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isMobile ? _buildMobileNav(context) : _buildDesktopNav(context),
      ),
    );
  }

  Widget _buildDesktopNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,

                  child: Image.asset(
                    ImagePath.icon_img,
                    height: 55,
                    filterQuality: FilterQuality.high,
                  ),

                  // child: const Icon(Icons.restaurant_menu_outlined, color: Colors.white, size: 28),
                );
              },
            ),
            const SizedBox(width: 15),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF8B4513), Color(0xFF654321)],
              ).createShader(bounds),
              child: const Text(
                "Bulbul Hotel",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            'Home',
            'About',
            'Menu',
            'Reviews',
            'Contact',
          ].map((item) => _navButton(item)).toList(),
        ),
      ],
    );
  }

  Widget _buildMobileNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              ImagePath.icon_img,
              height: 118,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF8B4513), Color(0xFF654321)],
              ).createShader(bounds),
              child: const Text(
                "Bulbul",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.menu_rounded, size: 30),
          onPressed: () => _showMobileMenu(context),
        ),
      ],
    );
  }

  Widget _navButton(String label) {
    final isHovered = _hoveredItem == label;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredItem = label),
      onExit: (_) => setState(() => _hoveredItem = ''),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: TextButton(
          onPressed: () => widget.onNavigate(label),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: isHovered
                ? const Color(0xFFE8B86D).withOpacity(0.1)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isHovered ? FontWeight.w700 : FontWeight.w600,
              color: isHovered
                  ? const Color(0xFFE8B86D)
                  : const Color(0xFF2C1810),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Home', 'About', 'Menu', 'Reviews', 'Contact']
              .map(
                (item) => ListTile(
                  leading: Icon(
                    _getIconForSection(item),
                    color: const Color(0xFFE8B86D),
                  ),
                  title: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onNavigate(item);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  IconData _getIconForSection(String section) {
    switch (section) {
      case 'Home':
        return Icons.home_rounded;
      case 'About':
        return Icons.info_rounded;
      case 'Menu':
        return Icons.restaurant_menu_rounded;
      case 'Reviews':
        return Icons.star_rounded;
      case 'Contact':
        return Icons.contact_mail_rounded;
      default:
        return Icons.circle;
    }
  }
}

// ---------------------- HERO SECTION ----------------------
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.95,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ImagePath.bg_img),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated badge
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE8B86D), Color(0xFFD4A860)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE8B86D,
                                  ).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Text(
                              '✨ Serving Since 1985',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // Main title
                    const Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFFE8B86D)],
                      ).createShader(bounds),
                      child: const Text(
                        'Bulbul Hotel',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Authentic Pakistani Flavors & Gourmet Delights',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),

                    // Animated button
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1500),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: AnimatedButton(
                              onPressed: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE8B86D),
                                      Color(0xFFD4A860),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(35),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFE8B86D,
                                      ).withOpacity(0.4),
                                      blurRadius: 25,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Explore Our Menu',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------- ANIMATED BUTTON WIDGET ----------------------
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const AnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

// ---------------------- ABOUT SECTION ----------------------
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 100,
        vertical: isMobile ? 60 : 120,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFFBF5),
            const Color(0xFFE8B86D).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          _SectionHeader(title: 'Our Story'),
          const SizedBox(height: 60),
          isMobile
              ? Column(
                  children: [
                    _AboutImage(),
                    const SizedBox(height: 40),
                    _AboutContent(),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _AboutImage()),
                    const SizedBox(width: 80),
                    Expanded(child: _AboutContent()),
                  ],
                ),
        ],
      ),
    );
  }
}

class _AboutImage extends StatefulWidget {
  @override
  State<_AboutImage> createState() => _AboutImageState();
}

class _AboutImageState extends State<_AboutImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_controller.value * 2 * math.pi) * 10),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8B86D).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.asset(
            ImagePath.about_img,
            height: 500,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE8B86D).withOpacity(0.2),
                const Color(0xFFE8B86D).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFFE8B86D), size: 20),
              SizedBox(width: 8),
              Text(
                'Tradition • Quality • Excellence',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B4513),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'A Legacy of Authentic Flavors',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2C1810),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Since 1985, Bulbul Cafe has been the heart of Sahiwal\'s culinary scene. '
          'We take pride in serving traditional Pakistani dishes prepared with authentic recipes '
          'passed down through generations.',
          style: TextStyle(
            fontSize: 18,
            height: 1.8,
            color: Colors.grey[700],
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Every dish tells a story of heritage, passion, and dedication to excellence. '
          'From our signature handis to aromatic biryanis, we bring you flavors that feel like home.',
          style: TextStyle(
            fontSize: 18,
            height: 1.8,
            color: Colors.grey[700],
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            _StatCard(number: '38+', label: 'Years'),
            const SizedBox(width: 20),
            _StatCard(number: '50K+', label: 'Happy Customers'),
            const SizedBox(width: 20),
            _StatCard(number: '100+', label: 'Dishes'),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;

  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8B86D), Color(0xFFD4A860)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8B86D).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- SECTION HEADER ----------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C1810),
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Container(
          height: 5,
          width: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8B86D), Color(0xFFD4A860)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 15),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

// ---------------------- MENU SECTION ----------------------
class MenuSection extends StatelessWidget {
  const MenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 100,
        vertical: isMobile ? 60 : 120,
      ),
      color: Colors.white,
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Signature Dishes',
            subtitle: 'Crafted with passion, served with love',
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _MenuCard(
                image:
                    'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=600&q=80',
                title: 'Chicken Karahi',
                description:
                    'Tender chicken in aromatic tomato gravy with traditional spices',
                price: 'Rs. 850',
                delay: 0,
              ),
              _MenuCard(
                image:
                    'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&q=80',
                title: 'Mutton Biryani',
                description:
                    'Fragrant basmati rice layered with succulent mutton pieces',
                price: 'Rs. 950',
                delay: 200,
              ),
              _MenuCard(
                image:
                    'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=600&q=80',
                title: 'Seekh Kabab',
                description: 'Juicy minced meat kababs grilled to perfection',
                price: 'Rs. 650',
                delay: 400,
              ),
              _MenuCard(
                image:
                    'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&q=80',
                title: 'Nihari',
                description:
                    'Slow-cooked beef stew with bone marrow and aromatic spices',
                price: 'Rs. 750',
                delay: 600,
              ),
              _MenuCard(
                image:
                    'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&q=80',
                title: 'Dal Makhani',
                description:
                    'Creamy black lentils slow-cooked with butter and cream',
                price: 'Rs. 450',
                delay: 800,
              ),
              _MenuCard(
                image:
                    'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=600&q=80',
                title: 'Chicken Tikka',
                description:
                    'Marinated chicken chunks grilled in tandoor with spices',
                price: 'Rs. 700',
                delay: 1000,
              ),
              _MenuCard(
                image:
                    'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600&q=80',
                title: 'Haleem',
                description: 'Traditional wheat and meat stew cooked overnight',
                price: 'Rs. 550',
                delay: 1200,
              ),

              _MenuCard(
                image:
                    'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=600&q=80',
                title: 'Butter Chicken',
                description: 'Creamy tomato curry with tender chicken pieces',
                price: 'Rs. 800',
                delay: 1600,
              ),
              _MenuCard(
                image:
                    'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=600&q=80',
                title: 'Chicken Handi',
                description:
                    'Boneless chicken cooked in yogurt and cream sauce',
                price: 'Rs. 900',
                delay: 1800,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final String price;
  final int delay;

  const _MenuCard({
    required this.image,
    required this.title,
    required this.description,
    required this.price,
    required this.delay,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -10.0 : 0.0),
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0xFFE8B86D).withOpacity(0.4)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: _isHovered ? 30 : 15,
                  spreadRadius: _isHovered ? 5 : 2,
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                        child: Image.network(
                          widget.image,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE8B86D), Color(0xFFD4A860)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.price,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C1810),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8B86D),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Order Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------- REVIEWS SECTION ----------------------
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  final List<Map<String, String>> reviews = const [
  {
    "name": "Ahmed Khan",
    "review": "Amazing food and cozy ambiance! The BBQ platter is outstanding.",
    "image": "https://i.pravatar.cc/150?img=12",
  },
  {
    "name": "Sara Ali",
    "review": "Best biryani in town! Authentic taste that reminds me of home.",
    "image": "https://i.pravatar.cc/150?img=47",
  },
  {
    "name": "Bilal Sheikh",
    "review": "Friendly staff and delicious food. Highly recommended!",
    "image": "https://i.pravatar.cc/150?img=33",
  },
  {
    "name": "Fatima Hassan",
    "review": "The karahi chicken is to die for. Perfect spice level!",
    "image": "https://i.pravatar.cc/150?img=45",
  },
  {
    "name": "Usman Tariq",
    "review": "Great coffee and amazing breakfast options. Love this place!",
    "image": "https://i.pravatar.cc/150?img=52",
  },
  {
    "name": "Ayesha Malik",
    "review": "The nihari here is absolutely authentic! Takes me back to my grandmother's kitchen.",
    "image": "https://i.pravatar.cc/150?img=38",
  },
  {
    "name": "Hassan Raza",
    "review": "Best seekh kababs in Sahiwal! The chapli kabab is also mind-blowing.",
    "image": "https://i.pravatar.cc/150?img=14",
  },
  {
    "name": "Zainab Siddiqui",
    "review": "Their desi chai and haleem combo is perfection. Family-friendly atmosphere!",
    "image": "https://i.pravatar.cc/150?img=44",
  },
];
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 100,
        vertical: isMobile ? 60 : 120,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFFBF5),
            const Color(0xFFE8B86D).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Customer Reviews',
            subtitle: 'What our valued customers say about us',
          ),
          const SizedBox(height: 60),
          SizedBox(
            height: 320,
            child: PageView.builder(
              controller: PageController(
                viewportFraction: isMobile ? 0.9 : 0.4,
              ),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return _ReviewCard(
                  image: review["image"]!,
                  name: review["name"]!,
                  review: review["review"]!,
                  rating: 4,
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final String image;
  final String name;
  final String review;
  final int rating;
  final int index;

  const _ReviewCard({
    required this.image,
    required this.name,
    required this.review,
    required this.rating,
    required this.index,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_animation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFFFFBF5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE8B86D).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE8B86D),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE8B86D).withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: NetworkImage(widget.image),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF2C1810),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.rating,
                      (index) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.star_rounded,
                          color: Color(0xFFE8B86D),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '"${widget.review}"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------- CONTACT SECTION ----------------------
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 100,
        vertical: isMobile ? 60 : 120,
      ),
      color: Colors.white,
      child: Column(
        children: [
          const _SectionHeader(
            title: 'Get In Touch',
            subtitle: 'We\'d love to hear from you',
          ),
          const SizedBox(height: 60),
          isMobile
              ? Column(children: [_ContactInfo()])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_ContactInfo()],
                ),
        ],
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: const [
            SizedBox(
              width: 250,
              child: _InfoCard(
                icon: Icons.location_on_rounded,
                title: 'Visit Us',
                info: '123 Main Street\nSahiwal, Punjab\nPakistan',
                gradient: [Color(0xFFE8B86D), Color(0xFFD4A860)],
              ),
            ),
            SizedBox(
              width: 250,
              child: _InfoCard(
                icon: Icons.phone_rounded,
                title: 'Call Us',
                info: '+92 300 1234567\n+92 300 7654321',
                gradient: [Color(0xFF8B4513), Color(0xFF654321)],
              ),
            ),
            SizedBox(
              width: 250,
              child: _InfoCard(
                icon: Icons.email_rounded,
                title: 'Email Us',
                info: 'info@bulbulcafe.com\nsupport@bulbulcafe.com',
                gradient: [Color(0xFFE8B86D), Color(0xFFD4A860)],
              ),
            ),
            SizedBox(
              width: 250,
              child: _InfoCard(
                icon: Icons.access_time_rounded,
                title: 'Working Hours',
                info: 'Monday - Sunday\n8:00 AM - 11:00 PM',
                gradient: [Color(0xFF8B4513), Color(0xFF654321)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String info;
  final List<Color> gradient;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.info,
    required this.gradient,
  });

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -5.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0xFFE8B86D).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: _isHovered ? 20 : 10,
              spreadRadius: _isHovered ? 3 : 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: widget.gradient),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient[0].withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.info,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- FOOTER SECTION ----------------------
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 100,
        vertical: isMobile ? 50 : 80,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C1810), Color(0xFF1A0F0A)],
        ),
      ),
      child: Column(
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FooterBrand(),
                    const SizedBox(height: 40),
                    _FooterLinks(),
                    const SizedBox(height: 30),
                    _FooterContact(),
                    const SizedBox(height: 30),
                    _SocialLinks(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _FooterBrand()),
                    Expanded(child: _FooterLinks()),
                    Expanded(child: _FooterContact()),
                    Expanded(child: _SocialLinks()),
                  ],
                ),
          const SizedBox(height: 50),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Color(0xFFE8B86D), size: 20),
              const SizedBox(width: 8),
              Text(
                '© ${DateTime.now().year} Bulbul Cafe. Crafted with love in Pakistan',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                    ImagePath.icon_img,
                    height: 55,
                    filterQuality: FilterQuality.high,
                  ),

            ),
            const SizedBox(width: 15),
            const Text(
              'Bulbul Cafe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Serving authentic Pakistani cuisine\nwith passion since 1985.\nExperience the true taste of tradition.',
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.8),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Links',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ...['Home', 'About Us', 'Menu', 'Reviews', 'Contact'].map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFE8B86D),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    link,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Contact Info',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20),
        Text(
          '📍 123 Main Street\n   Sahiwal, Pakistan',
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.8),
        ),
        SizedBox(height: 12),
        Text(
          '📞 +92 300 1234567',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
        SizedBox(height: 12),
        Text(
          '✉️ info@bulbulcafe.com',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
      ],
    );
  }
}

class _SocialLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Follow Us',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _SocialButton(icon: Icons.facebook, color: const Color(0xFF1877F2)),
            const SizedBox(width: 12),
            _SocialButton(
              icon: Icons.camera_alt,
              color: const Color(0xFFE4405F),
            ),
            const SizedBox(width: 12),
            _SocialButton(
              icon: Icons.phone_android,
              color: const Color(0xFF25D366),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _SocialButton({required this.icon, required this.color});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isHovered
              ? widget.color
              : const Color(0xFFE8B86D).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(
          widget.icon,
          color: _isHovered ? Colors.white : const Color(0xFFE8B86D),
          size: 24,
        ),
      ),
    );
  }
}
