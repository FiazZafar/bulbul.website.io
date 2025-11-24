// ignore_for_file: deprecated_member_use

import 'package:bulbul_project/image_path.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:html' hide VoidCallback;
import 'dart:ui_web' as ui;

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
        primaryColor: const Color(0xFF2D1B00),
        scaffoldBackgroundColor: const Color(0xFFFFF8E7),
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35),
          primary: const Color(0xFFFF6B35),
          secondary: const Color(0xFFF7931E),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(5, (_) => GlobalKey());
  
  late AnimationController _floatingController;
  int _currentSection = 0;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    // Listen to scroll to update current section
    _scrollController.addListener(_updateCurrentSection);
  }

  void _updateCurrentSection() {
    for (int i = 0; i < _sectionKeys.length; i++) {
      final context = _sectionKeys[i].currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          if (position.dy <= 200 && position.dy >= -500) {
            if (_currentSection != i) {
              setState(() => _currentSection = i);
            }
            break;
          }
        }
      }
    }
  }

  void _scrollToSection(int sectionIndex) {
    final context = _sectionKeys[sectionIndex].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
        alignment: 0.0,
      );
    }
  }

  void _navigateToSection(String label) {
    final sections = ['HOME', 'STORY', 'MENU', 'REVIEWS', 'CONNECT'];
    final index = sections.indexOf(label);
    if (index != -1) {
      _scrollToSection(index);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background shapes
          ...List.generate(5, (index) => _buildFloatingShape(index)),

          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                UniqueNavBar(
                  onItemTap: _navigateToSection,
                  currentSection: _currentSection,
                ),
                Container(key: _sectionKeys[0], child: const HeroSectionUnique()),
                Container(key: _sectionKeys[1], child: const AboutSectionUnique()),
                Container(key: _sectionKeys[2], child: const MenuSectionUnique()),
                Container(key: _sectionKeys[3], child: const ReviewsSectionUnique()),
                Container(key: _sectionKeys[4], child: ContactSectionUnique()),
                const FooterSectionUnique(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingShape(int index) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final offset = math.sin(_floatingController.value * 2 * math.pi + index) * 30;
        return Positioned(
          left: (index * 200.0) % MediaQuery.of(context).size.width,
          top: 100 + offset,
          child: Transform.rotate(
            angle: _floatingController.value * 2 * math.pi,
            child: Container(
              width: 80 + (index * 20),
              height: 80 + (index * 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6B35).withOpacity(0.1),
                    const Color(0xFFF7931E).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20 + index * 5),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== IMPROVED NAVBAR ====================
class UniqueNavBar extends StatefulWidget {
  final void Function(String label) onItemTap;
  final int currentSection;

  const UniqueNavBar({
    super.key,
    required this.onItemTap,
    required this.currentSection,
  });

  @override
  State<UniqueNavBar> createState() => _UniqueNavBarState();
}

class _UniqueNavBarState extends State<UniqueNavBar> {
  String _hoveredItem = '';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B00).withOpacity(0.95),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => widget.onItemTap('HOME'),
              child: Container(
                height: 50,
                width: 120,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  image: DecorationImage(image: AssetImage(ImagePath.logo_img),fit: BoxFit.cover)
                ),
                
              ),
            ),
          ),

          if (!isMobile)
            Row(
              children: [
                _buildNavItem('HOME', 0),
                _buildNavItem('STORY', 1),
                _buildNavItem('MENU', 2),
                _buildNavItem('REVIEWS', 3),
                _buildNavItem('CONNECT', 4),
              ],
            ),

          if (isMobile)
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onSelected: widget.onItemTap,
              itemBuilder: (BuildContext context) => [
                'HOME',
                'STORY',
                'MENU',
                'REVIEWS',
                'CONNECT',
              ].map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, int sectionIndex) {
    final isHovered = _hoveredItem == label;
    final isActive = widget.currentSection == sectionIndex;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredItem = label),
      onExit: (_) => setState(() => _hoveredItem = ''),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: TextButton(
          onPressed: () => widget.onItemTap(label),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: isActive
                ? const Color(0xFFFF6B35)
                : isHovered
                    ? const Color(0xFFFF6B35).withOpacity(0.7)
                    : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: isHovered || isActive ? 2 : 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== UNIQUE HERO SECTION ====================
class HeroSectionUnique extends StatefulWidget {
  const HeroSectionUnique({super.key});

  @override
  State<HeroSectionUnique> createState() => _HeroSectionUniqueState();
}

class _HeroSectionUniqueState extends State<HeroSectionUnique>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      width: double.infinity,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF2D1B00),
                        const Color(0xFF4A2C00),
                        math.sin(_controller.value * 2 * math.pi) * 0.5 + 0.5,
                      )!,
                      const Color(0xFF2D1B00),
                      Color.lerp(
                        const Color(0xFF1A0F00),
                        const Color(0xFF2D1B00),
                        math.cos(_controller.value * 2 * math.pi) * 0.5 + 0.5,
                      )!,
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: -100,
            top: size.height * 0.2,
            child: Opacity(
              opacity: 0.03,
              child: Transform.rotate(
                angle: -0.1,
                child: const Text(
                  'FOOD',
                  style: TextStyle(
                    fontSize: 300,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFF6B35),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'EST. 1985',
                      style: TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TASTE',
                            style: TextStyle(
                              fontSize: 90,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 0.9,
                              letterSpacing: -2,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                'THE',
                                style: TextStyle(
                                  fontSize: 90,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  height: 0.9,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF6B35),
                                      Color(0xFFF7931E),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
                                  'REAL',
                                  style: TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'PAKISTAN',
                            style: TextStyle(
                              fontSize: 90,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 0.9,
                              letterSpacing: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Where every bite tells a story of tradition, \npassion, and authentic Pakistani flavors.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      _UniqueCTAButton(
                        text: 'EXPLORE MENU',
                        isPrimary: true,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 20),
                      _UniqueCTAButton(
                        text: 'RESERVE TABLE',
                        isPrimary: false,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(right: 50, bottom: 50, child: _buildFloatingFoodElement()),
        ],
      ),
    );
  }

  Widget _buildFloatingFoodElement() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            math.cos(_controller.value * 2 * math.pi) * 20,
            math.sin(_controller.value * 2 * math.pi) * 20,
          ),
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF6B35).withOpacity(0.3),
                  const Color(0xFFFF6B35).withOpacity(0.0),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF7931E).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFFFF6B35).withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: 100,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UniqueCTAButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _UniqueCTAButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_UniqueCTAButton> createState() => _UniqueCTAButtonState();
}

class _UniqueCTAButtonState extends State<_UniqueCTAButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                  )
                : null,
            color: !widget.isPrimary ? Colors.transparent : null,
            border: !widget.isPrimary
                ? Border.all(color: Colors.white, width: 2)
                : null,
            borderRadius: BorderRadius.circular(0),
            boxShadow: _isHovered && widget.isPrimary
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                _isHovered
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_right_alt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ==================== UNIQUE ABOUT SECTION ====================
class AboutSectionUnique extends StatelessWidget {
  const AboutSectionUnique({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 120),
      color: const Color(0xFFFFF8E7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'OUR',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF2D1B00),
                    height: 1,
                  ),
                ),
                Stack(
                  children: [
                    Text(
                      'STORY',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = const Color(0xFFFF6B35),
                        height: 1,
                      ),
                    ),
                    const Text(
                      'STORY',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                        color: Colors.transparent,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  height: 4,
                  width: 80,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Since 1985, we\'ve been crafting authentic Pakistani cuisine that brings people together. Our secret? Fresh ingredients, traditional recipes, and a whole lot of heart.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.8,
                    color: Color(0xFF6B5B4E),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Every dish we serve is a celebration of our rich culinary heritage, prepared with the same passion and dedication that started it all.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    color: Color(0xFF9B8B7E),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: const [
                    _UniqueStatCard(
                      number: '38+',
                      label: 'YEARS',
                      color: Color(0xFFFF6B35),
                    ),
                    SizedBox(width: 20),
                    _UniqueStatCard(
                      number: '50K+',
                      label: 'SERVED',
                      color: Color(0xFFF7931E),
                    ),
                    SizedBox(width: 20),
                    _UniqueStatCard(
                      number: '100+',
                      label: 'DISHES',
                      color: Color(0xFFFF6B35),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 100),
          Expanded(child: _buildAboutImageGrid()),
        ],
      ),
    );
  }

  Widget _buildAboutImageGrid() {
    return Stack(
      children: [
        // Background decorative element
        Positioned(
          top: -20,
          right: -20,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),

        // Main image container
        Container(
          margin: const EdgeInsets.only(top: 40, left: 40),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D1B00),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF6B35),
                          width: 3,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 80,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7931E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF7931E), width: 2),
                ),
                child: const Center(
                  child: Text(
                    '✨ AUTHENTIC FLAVORS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D1B00),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UniqueStatCard extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _UniqueStatCard({
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D1B00),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== UNIQUE MENU SECTION ====================
class MenuSectionUnique extends StatelessWidget {
  const MenuSectionUnique({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 120),
      color: const Color(0xFF2D1B00),
      child: Column(
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIGNATURE',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Stack(
                    children: [
                      Text(
                        'DISHES',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2
                            ..color = const Color(0xFFFF6B35),
                          height: 1,
                        ),
                      ),
                      const Text(
                        'DISHES',
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          color: Colors.transparent,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF6B35), width: 2),
                ),
                child: const Text(
                  'VIEW ALL →',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 80),

          // Menu grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 30,
            crossAxisSpacing: 30,
            childAspectRatio: 0.85,
            children: const [
              _UniqueMenuCard(
                title: 'CHICKEN\nKARAHI',
                price: '850',
                index: 0,
                img: ImagePath.chicken_krai,
              ),
              _UniqueMenuCard(
                title: 'MUTTON\nBIRYANI',
                price: '950',
                index: 1,
                img: ImagePath.mutton_krai,
              ),
              _UniqueMenuCard(
                title: 'SEEKH\nKABAB',
                price: '650',
                index: 2,
                img: ImagePath.seek_kbab,
              ),
              _UniqueMenuCard(
                title: 'BEEF\nNIHARI',
                price: '750',
                index: 3,
                img: ImagePath.beef_nihari,
              ),
              _UniqueMenuCard(
                title: 'DAL\nMAKHANI',
                price: '450',
                index: 4,
                img: ImagePath.daal_makhni,
              ),
              _UniqueMenuCard(
                title: 'CHICKEN\nTIKKA',
                price: '700',
                index: 5,
                img: ImagePath.chikken_tikka,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UniqueMenuCard extends StatefulWidget {
  final String title;
  final String price;
  final int index;
  final String img;

  const _UniqueMenuCard({
    required this.title,
    required this.price,
    required this.index,
    required this.img,
  });

  @override
  State<_UniqueMenuCard> createState() => _UniqueMenuCardState();
}

class _UniqueMenuCardState extends State<_UniqueMenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -10.0 : 0.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isHovered ? const Color(0xFFFF6B35) : Colors.white24,
            width: 2,
          ),
          color: _isHovered ? const Color(0xFF3D2B10) : Colors.transparent,
        ),
        child: Stack(
          children: [
            // Number
            Positioned(
              top: 20,
              right: 20,
              child: Text(
                '0${widget.index + 1}',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Container(
              height: MediaQuery.heightOf(context) * 0.5,
              width: MediaQuery.widthOf(context),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.img),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RS. ${widget.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== UNIQUE REVIEWS SECTION ====================
class ReviewsSectionUnique extends StatelessWidget {
  const ReviewsSectionUnique({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 120),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF8E7),
            const Color(0xFFFF6B35).withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'REVIEWS',
                style: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = const Color(0xFFFF6B35).withOpacity(0.1),
                ),
              ),
              const Text(
                'WHAT PEOPLE SAY',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2D1B00),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 80),

          // Reviews grid
          SizedBox(
            height: 400,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return _UniqueReviewCard(index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UniqueReviewCard extends StatelessWidget {
  final int index;

  const _UniqueReviewCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      margin: const EdgeInsets.only(right: 30),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.2),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ahmed Khan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D1B00),
                    ),
                  ),
                  Text(
                    'Food Enthusiast',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9B8B7E),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: List.generate(
              5,
              (i) => const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFF6B35),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '"The best biryani I\'ve ever tasted! Authentic flavors that remind me of home. The karahi is absolutely mind-blowing!"',
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: Color(0xFF6B5B4E),
              fontStyle: FontStyle.italic,
            ),
          ),
          const Spacer(),
          Container(
            height: 3,
            width: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== UNIQUE CONTACT SECTION ====================
class ContactSectionUnique extends StatelessWidget {
  ContactSectionUnique({super.key}) {
    // Register the map iframe
    ui.platformViewRegistry.registerViewFactory(
      'map-iframe',
      (int viewId) => IFrameElement()
        ..src =
            "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3432.3176797293563!2d73.1192334!3d30.653181699999994!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3922b7c123226b53%3A0x16d26960d9b4fb77!2sBulbul%20Hotel%20pakpattan%20chowk!5e0!3m2!1sen!2s!4v1763971643322!5m2!1sen!2s"
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 30,
        vertical: 80,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D1B00), Color(0xFF1A0F00)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildLeftContent()),
                const SizedBox(width: 60),
                Expanded(flex: 2, child: _buildRightContent(isDesktop)),
              ],
            )
          else
            Column(
              children: [
                _buildLeftContent(),
                const SizedBox(height: 40),
                _buildRightContent(isDesktop),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLeftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GET IN',
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            height: 1,
          ),
        ),
        Stack(
          children: [
            Text(
              'TOUCH',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = const Color(0xFFFF6B35),
                height: 1,
              ),
            ),
            const Text(
              'TOUCH',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w900,
                color: Colors.transparent,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        const Text(
          'Visit us, call us, or drop by for the best Pakistani food experience in Sahiwal.',
          style: TextStyle(fontSize: 18, color: Colors.white70, height: 1.8),
        ),
        const SizedBox(height: 50),
        _buildContactRow(
          Icons.location_on_rounded,
          'Main Street, Sahiwal, Pakistan',
        ),
        const SizedBox(height: 20),
        _buildContactRow(Icons.phone_rounded, '+92 300 1234567'),
        const SizedBox(height: 20),
        _buildContactRow(Icons.email_rounded, 'info@bulbulcafe.com'),
      ],
    );
  }

  Widget _buildRightContent(bool isDesktop) {
    return Column(
      children: [
        // Hours card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF6B35), width: 3),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'OPEN HOURS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Monday - Sunday',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              const Text(
                '8:00 AM - 11:00 PM',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Fixed map container
        Container(
          width: double.infinity,
          height: isDesktop ? 350 : 300,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF6B35), width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const HtmlElementView(viewType: 'map-iframe'),
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF6B35), width: 2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFFF6B35), size: 24),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ==================== UNIQUE FOOTER SECTION ====================
class FooterSectionUnique extends StatelessWidget {
  const FooterSectionUnique({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(60),
      color: const Color(0xFF1A0F00),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70,
                    width: 170,
                    padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                      ),
                      shape: BoxShape.rectangle,
                      image: DecorationImage(image: AssetImage(ImagePath.logo_img),fit: BoxFit.cover)
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Authentic Pakistani Cuisine',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),

              // Social icons
              Row(
                children: [
                  _buildSocialIcon(Icons.facebook),
                  const SizedBox(width: 15),
                  _buildSocialIcon(Icons.camera_alt),
                  const SizedBox(width: 15),
                  _buildSocialIcon(Icons.phone_android),
                ],
              ),
            ],
          ),

          const SizedBox(height: 60),

          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  const Color(0xFFFF6B35).withOpacity(0.3),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Color(0xFFFF6B35), size: 16),
              const SizedBox(width: 10),
              Text(
                '© ${DateTime.now().year} BULBUL CAFE. CRAFTED WITH PASSION',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.3),
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFFFF6B35), size: 20),
    );
  }
}
