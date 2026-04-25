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
      ),
      home: const HomePage(),
    );
  }
}

// ==================== RESPONSIVE HELPER CLASS ====================
class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static double getResponsiveFontSize(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return size * 0.5;
    if (width < 900) return size * 0.7;
    return size;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600)
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 40);
    if (width < 900)
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 60);
    return const EdgeInsets.symmetric(horizontal: 60, vertical: 80);
  }
}

// ==================== HOME PAGE ====================
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
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scrollController.addListener(_updateCurrentSection);
  }

  void _updateCurrentSection() {
    if (_isScrolling) return;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final context = _sectionKeys[i].currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          if (position.dy <= 150 && position.dy >= -200) {
            if (_currentSection != i) {
              setState(() => _currentSection = i);
            }
            break;
          }
        }
      }
    }
  }

  void _scrollToSection(int sectionIndex) async {
    setState(() {
      _currentSection = sectionIndex;
      _isScrolling = true;
    });

    final context = _sectionKeys[sectionIndex].currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        alignment: 0.0,
      );
    }

    await Future.delayed(const Duration(milliseconds: 900));
    _isScrolling = false;
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
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      body: Stack(
        children: [
          // Animated background shapes - fewer on mobile
          if (!isMobile)
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
                Container(
                  key: _sectionKeys[0],
                  child: const HeroSectionResponsive(),
                ),
                Container(
                  key: _sectionKeys[1],
                  child: const AboutSectionResponsive(),
                ),
                Container(
                  key: _sectionKeys[2],
                  child: const MenuSectionResponsive(),
                ),
                Container(
                  key: _sectionKeys[3],
                  child: const ReviewsSectionResponsive(),
                ),
                Container(
                  key: _sectionKeys[4],
                  child: ContactSectionResponsive(),
                ),
                const FooterSectionResponsive(),
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
        final offset =
            math.sin(_floatingController.value * 2 * math.pi + index) * 30;
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

// ==================== RESPONSIVE NAVBAR ====================
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
      margin: EdgeInsets.all(isMobile ? 10 : 20),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 15 : 30,
        vertical: isMobile ? 10 : 15,
      ),
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
                height: isMobile ? 40 : 50,
                width: isMobile ? 100 : 120,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  image: DecorationImage(
                    image: AssetImage(ImagePath.logo_img),
                    fit: BoxFit.cover,
                  ),
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
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 28,
              ),
              onSelected: widget.onItemTap,
              color: const Color(0xFF2D1B00),
              itemBuilder: (BuildContext context) =>
                  ['HOME', 'STORY', 'MENU', 'REVIEWS', 'CONNECT'].map((
                    String item,
                  ) {
                    final index = [
                      'HOME',
                      'STORY',
                      'MENU',
                      'REVIEWS',
                      'CONNECT',
                    ].indexOf(item);
                    final isActive = widget.currentSection == index;
                    return PopupMenuItem<String>(
                      value: item,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFFF6B35).withOpacity(0.2)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFFFF6B35)
                                : Colors.white,
                            fontWeight: isActive
                                ? FontWeight.w900
                                : FontWeight.w600,
                          ),
                        ),
                      ),
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
                ? const Color(0xFFFF6B35).withOpacity(0.5)
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
              fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              letterSpacing: isHovered || isActive ? 2 : 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== RESPONSIVE HERO SECTION ====================
class HeroSectionResponsive extends StatefulWidget {
  const HeroSectionResponsive({super.key});

  @override
  State<HeroSectionResponsive> createState() => _HeroSectionResponsiveState();
}

class _HeroSectionResponsiveState extends State<HeroSectionResponsive>
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
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return SizedBox(
      height: isMobile ? size.height * 0.7 : size.height ,
      width: double.infinity,
      child: Stack(
        children: [
          // Background gradient
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

          // Background text - hide on mobile
          if (!isMobile)
            Positioned(
              right: -100,
              top: size.height * 0.2,
              child: Opacity(
                opacity: 0.03,
                child: Transform.rotate(
                  angle: -0.1,
                  child: Text(
                    'FOOD',
                    style: TextStyle(
                      fontSize: isTablet ? 150 : 300,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // Main content
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : (isTablet ? 40 : 60),
                  vertical: isMobile ? 40 : 60,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isMobile ? 80 : 100),

                    // Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 15 : 20,
                        vertical: isMobile ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFF6B35),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'EST. 1985',
                        style: TextStyle(
                          color: const Color(0xFFFF6B35),
                          fontSize: isMobile ? 10 : 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                    ),

                    SizedBox(height: isMobile ? 20 : 30),

                    // Main title
                    if (isMobile)
                      _buildMobileTitle()
                    else
                      _buildDesktopTitle(isTablet),

                    SizedBox(height: isMobile ? 20 : 30),

                    // Subtitle
                    Text(
                      'Where every bite tells a story of tradition,\npassion, and authentic Pakistani flavors.',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : (isTablet ? 16 : 18),
                        color: Colors.white70,
                        height: 1.6,
                        letterSpacing: 0.5,
                      ),
                    ),

                    SizedBox(height: isMobile ? 30 : 50),

                    // CTA Buttons
                    isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ResponsiveCTAButton(
                                text: 'EXPLORE MENU',
                                isPrimary: true,
                                onPressed: () {},
                              ),
                              const SizedBox(height: 15),
                              _ResponsiveCTAButton(
                                text: 'RESERVE TABLE',
                                isPrimary: false,
                                onPressed: () {},
                              ),
                            ],
                          )
                        : Wrap(
                            spacing: 20,
                            runSpacing: 15,
                            children: [
                              _ResponsiveCTAButton(
                                text: 'EXPLORE MENU',
                                isPrimary: true,
                                onPressed: () {},
                              ),
                              _ResponsiveCTAButton(
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
          ),

          // Floating element - hide on mobile
          if (!isMobile)
            Positioned(
              right: isTablet ? 20 : 50,
              bottom: isTablet ? 20 : 50,
              child: _buildFloatingFoodElement(isTablet),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TASTE THE',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'REAL PAKISTAN',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTitle(bool isTablet) {
    final fontSize = isTablet ? 50.0 : 90.0;
    final realFontSize = isTablet ? 45.0 : 80.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TASTE',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 0.9,
            letterSpacing: -2,
          ),
        ),
        Row(
          children: [
            Text(
              'THE',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                height: 0.9,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 20),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 30,
                vertical: isTablet ? 8 : 10,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'REAL',
                style: TextStyle(
                  fontSize: realFontSize,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
        Text(
          'PAKISTAN',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 0.9,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingFoodElement(bool isTablet) {
    final size = isTablet ? 250.0 : 400.0;
    final innerSize = isTablet ? 180.0 : 300.0;
    final iconSize = isTablet ? 60.0 : 100.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            math.cos(_controller.value * 2 * math.pi) * 20,
            math.sin(_controller.value * 2 * math.pi) * 20,
          ),
          child: Container(
            width: size,
            height: size,
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
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF7931E).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFFFF6B35).withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: iconSize,
                    color: const Color(0xFFFF6B35),
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

// ==================== RESPONSIVE CTA BUTTON ====================
class _ResponsiveCTAButton extends StatefulWidget {
  final String text;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _ResponsiveCTAButton({
    required this.text,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  State<_ResponsiveCTAButton> createState() => _ResponsiveCTAButtonState();
}

class _ResponsiveCTAButtonState extends State<_ResponsiveCTAButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 30 : 40,
            vertical: isMobile ? 15 : 20,
          ),
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
            mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 12 : 14,
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
                size: isMobile ? 18 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Continue in next part due to length...
// ==================== ABOUT SECTION RESPONSIVE ====================
class AboutSectionResponsive extends StatelessWidget {
  const AboutSectionResponsive({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Container(
      padding: padding,
      color: const Color(0xFFFFF8E7),
      child: isMobile
          ? Column(
              children: [
                _buildLeftContent(context),
                const SizedBox(height: 40),
                _buildRightContent(context),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildLeftContent(context)),
                SizedBox(width: isTablet ? 40 : 100),
                Expanded(child: _buildRightContent(context)),
              ],
            ),
    );
  }

  Widget _buildLeftContent(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 15),
          decoration: const BoxDecoration(
            color: Color(0xFFFF6B35),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: isMobile ? 24 : 30,
          ),
        ),
        SizedBox(height: isMobile ? 20 : 30),
        Text(
          'OUR',
          style: TextStyle(
            fontSize: isMobile ? 32 : (isTablet ? 45 : 60),
            fontWeight: FontWeight.w300,
            color: const Color(0xFF2D1B00),
            height: 1,
          ),
        ),
        Stack(
          children: [
            Text(
              'STORY',
              style: TextStyle(
                fontSize: isMobile ? 32 : (isTablet ? 45 : 60),
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = const Color(0xFFFF6B35),
                height: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 20 : 30),
        Container(
          height: 4,
          width: isMobile ? 60 : 80,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
            ),
          ),
        ),
        SizedBox(height: isMobile ? 20 : 30),
        Text(
          'Since 1985, we\'ve been crafting authentic Pakistani cuisine that brings people together. Our secret? Fresh ingredients, traditional recipes, and a whole lot of heart.',
          style: TextStyle(
            fontSize: isMobile ? 14 : (isTablet ? 16 : 18),
            height: 1.8,
            color: const Color(0xFF6B5B4E),
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: isMobile ? 15 : 20),
        Text(
          'Every dish we serve is a celebration of our rich culinary heritage, prepared with the same passion and dedication that started it all.',
          style: TextStyle(
            fontSize: isMobile ? 13 : (isTablet ? 14 : 16),
            height: 1.8,
            color: const Color(0xFF9B8B7E),
          ),
        ),
        SizedBox(height: isMobile ? 30 : 40),
        isMobile
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      _ResponsiveStatCard(
                        number: '38+',
                        label: 'YEARS',
                        color: Color(0xFFFF6B35),
                      ),
                      SizedBox(width: 15),
                      _ResponsiveStatCard(
                        number: '50K+',
                        label: 'SERVED',
                        color: Color(0xFFF7931E),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  _ResponsiveStatCard(
                    number: '100+',
                    label: 'DISHES',
                    color: Color(0xFFFF6B35),
                  ),
                ],
              )
            : Row(
                children: const [
                  _ResponsiveStatCard(
                    number: '38+',
                    label: 'YEARS',
                    color: Color(0xFFFF6B35),
                  ),
                  SizedBox(width: 15),
                  _ResponsiveStatCard(
                    number: '50K+',
                    label: 'SERVED',
                    color: Color(0xFFF7931E),
                  ),
                  SizedBox(width: 15),
                  _ResponsiveStatCard(
                    number: '100+',
                    label: 'DISHES',
                    color: Color(0xFFFF6B35),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildRightContent(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 500),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: isMobile ? 150 : (isTablet ? 180 : 250),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D1B00),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFF6B35),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: isMobile ? 50 : (isTablet ? 60 : 80),
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: isMobile ? 150 : (isTablet ? 180 : 250),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: isMobile ? 50 : (isTablet ? 60 : 80),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: isMobile ? 100 : (isTablet ? 120 : 150),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF7931E).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF7931E), width: 2),
              ),
              child: Center(
                child: Text(
                  '✨ AUTHENTIC FLAVORS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : (isTablet ? 20 : 24),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2D1B00),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveStatCard extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _ResponsiveStatCard({
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 15 : 20),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          SizedBox(height: isMobile ? 3 : 5),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D1B00),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== MENU SECTION RESPONSIVE ====================
class MenuSectionResponsive extends StatelessWidget {
  const MenuSectionResponsive({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Container(
      padding: padding,
      color: const Color(0xFF2D1B00),
      child: Column(
        children: [
          // Header
          isMobile
              ? Column(
                  children: [
                    _buildMenuHeader(context),
                    const SizedBox(height: 20),
                    _buildViewAllButton(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_buildMenuHeader(context), _buildViewAllButton()],
                ),

          SizedBox(height: isMobile ? 40 : (isTablet ? 60 : 80)),

          // Menu Grid
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 3;
              if (isMobile) {
                crossAxisCount = 1;
              } else if (isTablet) {
                crossAxisCount = 2;
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: isMobile ? 20 : 30,
                crossAxisSpacing: isMobile ? 20 : 30,
                childAspectRatio: isMobile ? 1.2 : (isTablet ? 0.9 : 0.85),
                children: const [
                  _ResponsiveMenuCard(
                    title: 'CHICKEN\nKARAHI',
                    price: '850',
                    index: 0,
                    img: ImagePath.chicken_krai,
                  ),
                  _ResponsiveMenuCard(
                    title: 'MUTTON\nBIRYANI',
                    price: '950',
                    index: 1,
                    img: ImagePath.mutton_krai,
                  ),
                  _ResponsiveMenuCard(
                    title: 'SEEKH\nKABAB',
                    price: '650',
                    index: 2,
                    img: ImagePath.seek_kbab,
                  ),
                  _ResponsiveMenuCard(
                    title: 'BEEF\nNIHARI',
                    price: '750',
                    index: 3,
                    img: ImagePath.beef_nihari,
                  ),
                  _ResponsiveMenuCard(
                    title: 'DAL\nMAKHANI',
                    price: '450',
                    index: 4,
                    img: ImagePath.daal_makhni,
                  ),
                  _ResponsiveMenuCard(
                    title: 'CHICKEN\nTIKKA',
                    price: '700',
                    index: 5,
                    img: ImagePath.chikken_tikka,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuHeader(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'SIGNATURE',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isMobile ? 32 : (isTablet ? 45 : 60),
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
          ),
        ),
        Stack(
          children: [
            Text(
              'DISHES',
              textAlign: isMobile ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: isMobile ? 32 : (isTablet ? 45 : 60),
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = const Color(0xFFFF6B35),
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewAllButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFF6B35), width: 2),
      ),
      child: const Text(
        'VIEW ALL →',
        style: TextStyle(
          color: Color(0xFFFF6B35),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _ResponsiveMenuCard extends StatefulWidget {
  final String title;
  final String price;
  final int index;
  final String img;

  const _ResponsiveMenuCard({
    required this.title,
    required this.price,
    required this.index,
    required this.img,
  });

  @override
  State<_ResponsiveMenuCard> createState() => _ResponsiveMenuCardState();
}

class _ResponsiveMenuCardState extends State<_ResponsiveMenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered && !isMobile ? -10.0 : 0.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: _isHovered ? const Color(0xFFFF6B35) : Colors.white24,
            width: 2,
          ),
          color: _isHovered ? const Color(0xFF3D2B10) : Colors.transparent,
          borderRadius: BorderRadius.circular(isMobile ? 15 : 0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 15 : 0),
          child: Stack(
            children: [
              // Background number
              Positioned(
                top: 10,
                right: 10,
                child: Text(
                  '0${widget.index + 1}',
                  style: TextStyle(
                    fontSize: isMobile ? 40 : 80,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),

              // Image background
              Positioned.fill(
                child: Image.asset(
                  widget.img,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3),
                  colorBlendMode: BlendMode.darken,
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 20 : 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 8 : 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: Colors.white,
                          size: isMobile ? 20 : 30,
                        ),
                      ),
                      SizedBox(height: isMobile ? 10 : 15),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: isMobile ? 10 : 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RS. ${widget.price}',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFFF6B35),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(isMobile ? 6 : 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: isMobile ? 16 : 20,
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ==================== REVIEWS SECTION RESPONSIVE ====================
class ReviewsSectionResponsive extends StatelessWidget {
  const ReviewsSectionResponsive({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Container(
      padding: padding,
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
              if (!isMobile)
                Text(
                  'REVIEWS',
                  style: TextStyle(
                    fontSize: isTablet ? 80 : 120,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..color = const Color(0xFFFF6B35).withOpacity(0.1),
                  ),
                ),
              Text(
                'WHAT PEOPLE SAY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 24 : (isTablet ? 28 : 36),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D1B00),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 40 : (isTablet ? 60 : 80)),

          // Reviews list
          SizedBox(
            height: isMobile ? 330 : 400,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 10),
              itemBuilder: (context, index) {
                return _ResponsiveReviewCard(index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveReviewCard extends StatelessWidget {
  final int index;

  const _ResponsiveReviewCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: isMobile ? width * 0.85 : 350,
      margin: EdgeInsets.only(right: isMobile ? 15 : 30),
      padding: EdgeInsets.all(isMobile ? 25 : 40),
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
                width: isMobile ? 50 : 60,
                height: isMobile ? 50 : 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: isMobile ? 24 : 30,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahmed Khan',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D1B00),
                      ),
                    ),
                    Text(
                      'Food Enthusiast',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: const Color(0xFF9B8B7E),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFF6B35),
                  size: isMobile ? 18 : 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Text(
              '"The best biryani I\'ve ever tasted! Authentic flavors that remind me of home. The karahi is absolutely mind-blowing!"',
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                height: 1.8,
                color: const Color(0xFF6B5B4E),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 15),
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

// Continue in next message for Contact and Footer sections...
// ==================== CONTACT SECTION RESPONSIVE ====================
class ContactSectionResponsive extends StatelessWidget {
  ContactSectionResponsive({super.key}) {
    // Register map iframe
    ui.platformViewRegistry.registerViewFactory(
      'map-iframe-responsive',
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
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final padding = ResponsiveHelper.getResponsivePadding(context);

    return Container(
      padding: padding,
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
          if (isMobile)
            Column(
              children: [
                _buildLeftContent(context),
                const SizedBox(height: 40),
                _buildRightContent(context),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildLeftContent(context)),
                SizedBox(width: isTablet ? 40 : 60),
                Expanded(flex: 2, child: _buildRightContent(context)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLeftContent(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GET IN',
          style: TextStyle(
            fontSize: isMobile ? 32 : (isTablet ? 45 : 60),
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
                fontSize: isMobile ? 32 : (isTablet ? 45 : 60),
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = const Color(0xFFFF6B35),
                height: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 20 : 40),
        Text(
          'Visit us, call us, or drop by for the best Pakistani food experience in Sahiwal.',
          style: TextStyle(
            fontSize: isMobile ? 14 : 18,
            color: Colors.white70,
            height: 1.8,
          ),
        ),
        SizedBox(height: isMobile ? 30 : 50),
        _buildContactRow(
          Icons.location_on_rounded,
          'Main Street, Sahiwal, Pakistan',
          isMobile,
        ),
        const SizedBox(height: 20),
        _buildContactRow(Icons.phone_rounded, '+92 300 1234567', isMobile),
        const SizedBox(height: 20),
        _buildContactRow(Icons.email_rounded, 'info@bulbulcafe.com', isMobile),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF6B35), width: 2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFF6B35),
            size: isMobile ? 20 : 24,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRightContent(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Column(
      children: [
        // Hours card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 20 : 30),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF6B35), width: 3),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 15 : 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: isMobile ? 30 : 40,
                ),
              ),
              SizedBox(height: isMobile ? 15 : 20),
              Text(
                'OPEN HOURS',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: isMobile ? 10 : 15),
              Text(
                'Monday - Sunday',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Text(
                '8:00 AM - 11:00 PM',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Map container
        Container(
          width: double.infinity,
          height: isMobile ? 250 : (isTablet ? 300 : 350),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF6B35), width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: const HtmlElementView(viewType: 'map-iframe-responsive'),
          ),
        ),
      ],
    );
  }
}

// ==================== FOOTER SECTION RESPONSIVE ====================
class FooterSectionResponsive extends StatelessWidget {
  const FooterSectionResponsive({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 30 : 60),
      color: const Color(0xFF1A0F00),
      child: Column(
        children: [
          isMobile
              ? Column(
                  children: [
                    _buildBrandSection(isMobile),
                    const SizedBox(height: 30),
                    _buildSocialIcons(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_buildBrandSection(isMobile), _buildSocialIcons()],
                ),
          SizedBox(height: isMobile ? 40 : 60),
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
              Flexible(
                child: Text(
                  '© ${DateTime.now().year} BULBUL CAFE. CRAFTED WITH PASSION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: isMobile ? 10 : 12,
                    letterSpacing: isMobile ? 1 : 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSection(bool isMobile) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          height: isMobile ? 60 : 70,
          width: isMobile ? 150 : 170,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
            ),
            image: DecorationImage(
              image: AssetImage(ImagePath.logo_img),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Authentic Pakistani Cuisine',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: Colors.white54,
            fontSize: isMobile ? 12 : 14,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSocialIcon(Icons.facebook),
        const SizedBox(width: 15),
        _buildSocialIcon(Icons.camera_alt),
        const SizedBox(width: 15),
        _buildSocialIcon(Icons.phone_android),
      ],
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
