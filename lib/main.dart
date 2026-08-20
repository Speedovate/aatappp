import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AatapppWebsiteApp());
}

const _accent = Color(0xFF98CC3D);
const _surface = Color(0xFFF6F6F1);
const _ink = Color(0xFF111111);
const _muted = Color(0xFF666666);

class AatapppWebsiteApp extends StatelessWidget {
  const AatapppWebsiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AATAPPP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _surface,
        colorScheme: const ColorScheme.light(
          primary: _accent,
          secondary: _accent,
          surface: Colors.white,
          onPrimary: _ink,
          onSurface: _ink,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 72,
            height: 0.9,
            fontWeight: FontWeight.w700,
            letterSpacing: -2.8,
            color: _ink,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 50,
            height: 1.0,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.6,
            color: _ink,
          ),
          headlineMedium: TextStyle(
            fontSize: 30,
            height: 1.12,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
          bodyLarge: TextStyle(fontSize: 17, height: 1.8, color: _muted),
          bodyMedium: TextStyle(fontSize: 15, height: 1.75, color: _muted),
          labelLarge: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: _ink,
          ),
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
  final _scrollController = ScrollController();
  final _sectionKeys = {
    'Home': GlobalKey(),
    'About': GlobalKey(),
    'Mission': GlobalKey(),
    'Members': GlobalKey(),
    'Programs': GlobalKey(),
    'Events': GlobalKey(),
    'Leadership': GlobalKey(),
    'Partners': GlobalKey(),
  };
  String _activeSection = 'Home';
  bool _isScrolled = false;
  bool _isSnapping = false;
  double _dragDeltaY = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final nextScrolled =
        _scrollController.hasClients && _scrollController.offset > 24;
    String nextActive = _activeSection;
    double closest = double.infinity;

    for (final entry in _sectionKeys.entries) {
      final context = entry.value.currentContext;
      if (context == null) {
        continue;
      }
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) {
        continue;
      }
      final top = box.localToGlobal(Offset.zero).dy;
      final distance = (top - 132).abs();
      if (distance < closest) {
        closest = distance;
        nextActive = entry.key;
      }
    }

    if (nextScrolled != _isScrolled || nextActive != _activeSection) {
      setState(() {
        _isScrolled = nextScrolled;
        _activeSection = nextActive;
      });
    }
  }

  List<MapEntry<String, double>> _orderedSectionOffsets() {
    final offsets = <MapEntry<String, double>>[];
    for (final entry in _sectionKeys.entries) {
      final offset = _sectionOffset(entry.key);
      if (offset != null) {
        offsets.add(MapEntry(entry.key, offset));
      }
    }
    offsets.sort((a, b) => a.value.compareTo(b.value));
    return offsets;
  }

  void _scrollTo(String section) {
    final targetOffset = _sectionOffset(section);
    if (targetOffset == null || !_scrollController.hasClients) {
      return;
    }
    _isSnapping = true;
    _scrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        )
        .whenComplete(() {
          if (mounted) {
            _isSnapping = false;
          }
        });
  }

  double? _sectionOffset(String section) {
    final context = _sectionKeys[section]?.currentContext;
    if (context == null || !_scrollController.hasClients) {
      return null;
    }
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) {
      return null;
    }

    final scrollPosition = _scrollController.position;
    final viewportTop = scrollPosition.pixels;
    final topInViewport = box.localToGlobal(Offset.zero).dy;
    final rawOffset = viewportTop + topInViewport - 96;
    return rawOffset.clamp(
      scrollPosition.minScrollExtent,
      scrollPosition.maxScrollExtent,
    );
  }

  void _snapToAdjacentSection(int direction) {
    if (!_scrollController.hasClients || _isSnapping || direction == 0) {
      return;
    }

    final currentOffset = _scrollController.offset;
    final sections = _orderedSectionOffsets();
    if (sections.isEmpty) {
      return;
    }

    final currentIndex = sections.lastIndexWhere(
      (entry) => entry.value <= currentOffset + 8,
    );
    final baseIndex = currentIndex < 0 ? 0 : currentIndex;
    final targetIndex = direction > 0
        ? (baseIndex + 1).clamp(0, sections.length - 1)
        : (baseIndex - 1).clamp(0, sections.length - 1);

    final targetOffset = sections[targetIndex].value;
    if ((targetOffset - currentOffset).abs() < 8) {
      return;
    }

    _isSnapping = true;
    _scrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 560),
          curve: Curves.easeInOutCubic,
        )
        .whenComplete(() {
          if (mounted) {
            _isSnapping = false;
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1040;
    final navItems = _sectionKeys.keys.toList();

    return Scaffold(
      endDrawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: Colors.black,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: _LogoLockup(
                          compact: false,
                          dark: true,
                          showSubtitle: false,
                        ),
                      ),
                      const SizedBox(height: 24),
                      for (final item in navItems)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item,
                            style: TextStyle(
                              color: item == _activeSection
                                  ? _accent
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            _scrollTo(item);
                          },
                        ),
                      const Spacer(),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: _ink,
                          minimumSize: const Size(double.infinity, 54),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _scrollTo('Partners');
                        },
                        child: const Text('Join Us'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      body: Stack(
        children: [
          Listener(
            onPointerSignal: (event) {
              if (isDesktop &&
                  event is PointerScrollEvent &&
                  event.scrollDelta.dy.abs() > 0) {
                _snapToAdjacentSection(event.scrollDelta.dy > 0 ? 1 : -1);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: isDesktop
                  ? (_) {
                      _dragDeltaY = 0;
                    }
                  : null,
              onVerticalDragUpdate: isDesktop
                  ? (details) {
                      _dragDeltaY += details.primaryDelta ?? 0;
                    }
                  : null,
              onVerticalDragEnd: isDesktop
                  ? (details) {
                      final velocity = details.primaryVelocity ?? 0;
                      if (_dragDeltaY.abs() < 28 && velocity.abs() < 280) {
                        _dragDeltaY = 0;
                        return;
                      }
                      _snapToAdjacentSection(
                        _dragDeltaY < 0 || velocity < -280 ? 1 : -1,
                      );
                      _dragDeltaY = 0;
                    }
                  : null,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: isDesktop
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SectionAnchor(
                      key: _sectionKeys['Home'],
                      child: HeroSection(
                        onPrimaryTap: () => _scrollTo('Members'),
                      ),
                    ),
                    SectionAnchor(
                      key: _sectionKeys['About'],
                      child: const AboutSection(),
                    ),
                    SectionAnchor(
                      key: _sectionKeys['Mission'],
                      child: const MissionVisionSection(),
                    ),
                    SectionAnchor(
                      key: _sectionKeys['Members'],
                      child: const MembersSection(),
                    ),
                    SectionAnchor(
                      key: _sectionKeys['Programs'],
                      child: const ProgramsSection(),
                    ),
                    SectionAnchor(
                      key: _sectionKeys['Events'],
                      child: const EventsSection(),
                    ),
                    SectionAnchor(
                      key: _sectionKeys['Leadership'],
                      child: const LeadershipSection(),
                    ),
                    SectionAnchor(
                      key: _sectionKeys['Partners'],
                      child: const PartnersSection(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color:
                        (_isScrolled ? Colors.black : const Color(0xFF0A0A0A))
                            .withValues(alpha: _isScrolled ? 0.9 : 0.62),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: (_isScrolled ? Colors.white : _accent).withValues(
                        alpha: _isScrolled ? 0.08 : 0.12,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const _LogoLockup(
                          compact: true,
                          dark: true,
                          showSubtitle: false,
                        ),
                        const Spacer(),
                        if (isDesktop) ...[
                          for (final item in navItems)
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: _NavLink(
                                label: item,
                                active: item == _activeSection,
                                onTap: () => _scrollTo(item),
                              ),
                            ),
                          const SizedBox(width: 18),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: _ink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            onPressed: () => _scrollTo('Partners'),
                            child: const Text('Join Us'),
                          ),
                        ] else
                          Builder(
                            builder: (context) => IconButton(
                              onPressed: () =>
                                  Scaffold.of(context).openEndDrawer(),
                              icon: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionAnchor extends StatelessWidget {
  const SectionAnchor({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.onPrimaryTap});

  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final isDesktop = width >= 1040;
    final isTablet = width >= 760;
    final display = Theme.of(context).textTheme.displayLarge!;
    final heroStyle = isDesktop
        ? display.copyWith(fontSize: 64, height: 0.94)
        : display.copyWith(fontSize: isTablet ? 50 : 38, height: 0.94);
    final heroHeight = isDesktop
        ? (height > 0 ? height : 980.0)
        : math.max(height > 0 ? height : 980.0, isTablet ? 1080.0 : 920.0);

    return SizedBox(
      height: heroHeight,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Positioned(
              left: 24,
              right: 24,
              top: 106,
              child: IgnorePointer(
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              right: isDesktop ? -120 : -90,
              top: isDesktop ? 140 : 210,
              child: IgnorePointer(
                child: Container(
                  width: isDesktop ? 520 : 320,
                  height: isDesktop ? 520 : 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withValues(alpha: 0.04),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.06),
                        blurRadius: 180,
                        spreadRadius: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: isDesktop ? 40 : -10,
              top: isDesktop ? 210 : 260,
              child: IgnorePointer(
                child: Container(
                  width: isDesktop ? 280 : 190,
                  height: isDesktop ? 280 : 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withValues(alpha: 0.07),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.06),
                        blurRadius: 120,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -160,
              bottom: -150,
              child: IgnorePointer(
                child: Container(
                  width: isDesktop ? 500 : 280,
                  height: isDesktop ? 500 : 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accent.withValues(alpha: 0.06),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.08),
                        blurRadius: 180,
                        spreadRadius: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  isDesktop ? 132 : 116,
                  24,
                  isDesktop ? 84 : 72,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1420),
                  child: isDesktop
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              height: constraints.maxHeight,
                              child: Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 11,
                                      child: _HeroCopy(
                                        heroStyle: heroStyle,
                                        onPrimaryTap: onPrimaryTap,
                                      ),
                                    ),
                                    const SizedBox(width: 72),
                                    const SizedBox(
                                      width: 500,
                                      child: _HeroRightColumn(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 452),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _HeroCopy(
                                  heroStyle: heroStyle,
                                  onPrimaryTap: onPrimaryTap,
                                ),
                                const SizedBox(height: 28),
                                const _HeroHighlight(),
                                const SizedBox(height: 24),
                                const _HeroStatsRail(),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _surface.withValues(alpha: 0.08),
                      ],
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
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.heroStyle, required this.onPrimaryTap});

  final TextStyle heroStyle;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'Association of Accredited Tourist Accommodations of Puerto Princesa, Palawan, Inc.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: heroStyle.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            'We set the standard for accredited tourist accommodations through leadership, accreditation, coordination, and member growth across Puerto Princesa and Palawan.',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: Color(0xFFD7D7D7),
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: 16,
          runSpacing: 14,
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _ink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                shape: const StadiumBorder(),
              ),
              onPressed: onPrimaryTap,
              child: const Text('Our Members'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                final state = context.findAncestorStateOfType<_HomePageState>();
                state?._scrollTo('About');
              },
              child: const Text('About Us'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroRightColumn extends StatelessWidget {
  const _HeroRightColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_HeroHighlight(), SizedBox(height: 26), _HeroStatsRail()],
    );
  }
}

class _HeroHighlight extends StatelessWidget {
  const _HeroHighlight();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our network brings together accredited tourist accommodations across Puerto Princesa in one clear, credible association platform.',
            style: TextStyle(fontSize: 14, height: 1.52, color: _muted),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.08)),
          const SizedBox(height: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Core focus',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: _muted,
                ),
              ),
              SizedBox(height: 8),
              _MiniBullet('We represent accredited tourist accommodations'),
              _MiniBullet('We drive partnerships, training, and co-opetition'),
              _MiniBullet('We uphold standards and tourism growth'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'We speak for accredited hospitality with a clear institutional voice.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: _ink.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatsRail extends StatelessWidget {
  const _HeroStatsRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 420) {
            return const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: _StatChip(
                      title: 'Members',
                      value: '50+',
                      expand: true,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: _StatChip(
                      title: 'Officers & BODs',
                      value: '12',
                      expand: true,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 4,
                    child: _StatChip(
                      title: 'Working Commitee',
                      value: '12',
                      expand: true,
                    ),
                  ),
                ],
              ),
            );
          }

          return const Wrap(
            alignment: WrapAlignment.end,
            runAlignment: WrapAlignment.end,
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatChip(title: 'Members', value: '50+'),
              _StatChip(title: 'Officers & BODs', value: '12'),
              _StatChip(title: 'Working Commitee', value: '12'),
            ],
          );
        },
      ),
    );
  }
}

class _MiniBullet extends StatelessWidget {
  const _MiniBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: _accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.6, color: _ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.title,
    required this.value,
    this.expand = false,
  });

  final String title;
  final String value;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: expand ? double.infinity : null,
      height: expand ? double.infinity : null,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: expand ? double.infinity : 92,
            height: 1,
            color: _accent.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    if (expand) {
      return card;
    }

    return IntrinsicWidth(child: card);
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    return SectionShell(
      tone: SectionTone.light,
      bottomPadding: isDesktop ? 200 : null,
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: _SectionIntro(
                    eyebrow: 'ABOUT US',
                    title: 'We lead accredited accommodations with one voice.',
                    body:
                        'AATAPPP is the official association of accredited tourist accommodations in Puerto Princesa, Palawan. We lead industry coordination, professional standards, and member growth across the local hospitality sector.',
                  ),
                ),
                const SizedBox(width: 36),
                const SizedBox(width: 500, child: _AboutCard()),
              ],
            )
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionIntro(
                  eyebrow: 'ABOUT US',
                  title: 'We lead accredited accommodations with one voice.',
                  body:
                      'AATAPPP is the official association of accredited tourist accommodations in Puerto Princesa, Palawan. We lead industry coordination, professional standards, and member growth across the local hospitality sector.',
                ),
                SizedBox(height: 24),
                _AboutCard(),
              ],
            ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _ValueStrip(
            title: 'Partnerships',
            text:
                'We maintain strong working ties with local and nationally recognized tourism organizations.',
          ),
          _ValueStrip(
            title: 'Accreditation growth',
            text:
                'We expand accreditation through member assistance, training, and industry guidance.',
          ),
          _ValueStrip(
            title: 'Business support',
            text:
                'We strengthen collaboration that drives shared business growth.',
          ),
        ],
      ),
    );
  }
}

class _ValueStrip extends StatelessWidget {
  const _ValueStrip({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: _accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MissionVisionSection extends StatelessWidget {
  const MissionVisionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 960;
    return SectionShell(
      tone: SectionTone.dark,
      bottomPadding: isDesktop ? 200 : null,
      child: isDesktop
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MISSION & VISION',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatementCard(
                            title: 'Mission',
                            text:
                                'We build strong tourism partnerships, expand accreditation through assistance and training, support education and workforce readiness, coordinate with government for a safe and sustainable business environment, and create meaningful impact for members and the wider community.',
                          ),
                          SizedBox(height: 22),
                          _StatementCard(
                            title: 'Vision',
                            text:
                                'To be the premier organization in Puerto Princesa, Palawan, dedicated to promoting professionalism and high standards in accommodation services, fostering a spirit of co-opetition where members collaborate, uplift one another, and collectively achieve higher levels of excellence in business operations.',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 28),
                    Expanded(
                      flex: 10,
                      child: _MissionThemesCard(
                        title: 'Mission themes',
                        subtitle: 'Key priorities that guide the association.',
                        items: _missionThemePrimary,
                        secondaryTitle: 'Focus areas',
                        secondarySubtitle:
                            'Key areas the association continues to strengthen.',
                        secondaryItems: _missionThemeSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatementCard(
                  title: 'Mission',
                  text:
                      'We build strong tourism partnerships, expand accreditation through assistance and training, support education and workforce readiness, coordinate with government for a safe and sustainable business environment, and create meaningful impact for members and the wider community.',
                ),
                SizedBox(height: 18),
                _StatementCard(
                  title: 'Vision',
                  text:
                      'To be the premier organization in Puerto Princesa, Palawan, dedicated to promoting professionalism and high standards in accommodation services, fostering a spirit of co-opetition where members collaborate, uplift one another, and collectively achieve higher levels of excellence in business operations.',
                ),
                SizedBox(height: 18),
                _MissionThemesCard(
                  title: 'Mission themes',
                  subtitle: 'Key priorities that guide the association.',
                  items: _missionThemePrimary,
                ),
                SizedBox(height: 18),
                _MissionThemesCard(
                  title: 'Focus areas',
                  subtitle:
                      'Key areas the association continues to strengthen.',
                  items: _missionThemeSecondary,
                ),
              ],
            ),
    );
  }
}

class _StatementCard extends StatelessWidget {
  const _StatementCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: _accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionThemesCard extends StatelessWidget {
  const _MissionThemesCard({
    required this.title,
    required this.subtitle,
    required this.items,
    this.secondaryTitle,
    this.secondarySubtitle,
    this.secondaryItems,
  });

  final String title;
  final String subtitle;
  final List<String> items;
  final String? secondaryTitle;
  final String? secondarySubtitle;
  final List<String>? secondaryItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: _muted, height: 1.5),
          ),
          const SizedBox(height: 12),
          for (final item in items) _MiniBullet(item),
          if (secondaryTitle != null &&
              secondarySubtitle != null &&
              secondaryItems != null) ...[
            const SizedBox(height: 14),
            Text(
              secondaryTitle!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              secondarySubtitle!,
              style: const TextStyle(fontSize: 13, color: _muted, height: 1.5),
            ),
            const SizedBox(height: 12),
            for (final item in secondaryItems!) _MiniBullet(item),
          ],
        ],
      ),
    );
  }
}

class MembersSection extends StatelessWidget {
  const MembersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1000;
    return SectionShell(
      tone: SectionTone.light,
      contentAlignment: Alignment.topCenter,
      topPadding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Members',
            style: TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              color: _muted,
            ),
          ),
          const SizedBox(height: 28),
          isDesktop
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MemberBand(
                        title: 'Hotels & Resorts',
                        dark: true,
                        members: _hotelsAndResorts,
                      ),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: _MemberBand(
                        title: 'Mabuhay Accommodations',
                        dark: false,
                        members: _mabuhayAccommodations,
                      ),
                    ),
                  ],
                )
              : const Column(
                  children: [
                    _MemberBand(
                      title: 'Hotels & Resorts',
                      dark: true,
                      members: _hotelsAndResorts,
                    ),
                    SizedBox(height: 18),
                    _MemberBand(
                      title: 'Mabuhay Accommodations',
                      dark: false,
                      members: _mabuhayAccommodations,
                    ),
                  ],
                ),
          SizedBox(height: isDesktop ? 28 : 24),
        ],
      ),
    );
  }
}

class _MemberBand extends StatelessWidget {
  const _MemberBand({
    required this.title,
    required this.dark,
    required this.members,
  });

  final String title;
  final bool dark;
  final List<String> members;

  @override
  Widget build(BuildContext context) {
    final base = dark ? Colors.black : Colors.white;
    final text = dark ? Colors.white : _ink;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.black.withValues(alpha: dark ? 0 : 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 28,
                    height: 1.02,
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: dark ? _accent : Colors.black.withValues(alpha: 0.16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: members
                .map(
                  (member) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                      border: Border.all(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      member,
                      style: TextStyle(
                        color: text,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class ProgramsSection extends StatelessWidget {
  const ProgramsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return SectionShell(
      tone: SectionTone.dark,
      contentAlignment: Alignment.topCenter,
      topPadding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = wide
                  ? (constraints.maxWidth - 44) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 22,
                runSpacing: 22,
                children: _programs
                    .asMap()
                    .entries
                    .map(
                      (entry) => SizedBox(
                        width: cardWidth,
                        child: _ProgramCard(
                          index: '0${entry.key + 1}',
                          title: entry.value.title,
                          text: entry.value.text,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2026 → BEYOND',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: MediaQuery.sizeOf(context).width >= 900 ? 42 : 34,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Our strategic direction drives accredited hospitality, market visibility, digitalization, tourism growth, and institutional coordination.',
                  style: TextStyle(fontSize: 14, color: _muted, height: 1.6),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = wide
                        ? (constraints.maxWidth - 24) / 2
                        : constraints.maxWidth;
                    return Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: _plans
                          .asMap()
                          .entries
                          .map(
                            (entry) => SizedBox(
                              width: itemWidth,
                              child: _StrategyRow(
                                index: '0${entry.key + 1}',
                                text: entry.value,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.index,
    required this.title,
    required this.text,
  });

  final String index;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 64,
            height: 1,
            color: Colors.white.withValues(alpha: 0.16),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

class _StrategyRow extends StatelessWidget {
  const _StrategyRow({required this.index, required this.text});

  final String index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: const TextStyle(
              color: _accent,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5, color: _ink),
            ),
          ),
        ],
      ),
    );
  }
}

class EventsSection extends StatelessWidget {
  const EventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return SectionShell(
      tone: SectionTone.light,
      contentAlignment: Alignment.topCenter,
      topPadding: 24,
      child: wide
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Events',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    color: _muted,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 8, child: _PosterStack()),
                    SizedBox(width: 28),
                    Expanded(flex: 11, child: _EventTimeline()),
                  ],
                ),
              ],
            )
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Events',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    color: _muted,
                  ),
                ),
                SizedBox(height: 16),
                _PosterStack(),
                SizedBox(height: 28),
                _EventTimeline(),
              ],
            ),
    );
  }
}

class _EventTimeline extends StatelessWidget {
  const _EventTimeline();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    if (wide) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - 18) / 2;
          return Wrap(
            spacing: 18,
            runSpacing: 12,
            children: _events
                .map(
                  (event) => SizedBox(
                    width: cardWidth,
                    child: _EventCard(event: event),
                  ),
                )
                .toList(),
          );
        },
      );
    }

    return Column(
      children: _events
          .map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EventCard(event: event),
            ),
          )
          .toList(),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.month,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.day,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  event.venue,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _accent,
                    letterSpacing: 0.2,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.42,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterStack extends StatelessWidget {
  const _PosterStack();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(
          child: _PosterSlice(
            title: '2025 members’ appreciation night',
            subtitle:
                'Official event material for our 10th anniversary and members’ appreciation night.',
            imagePath: 'assets/aatappp/accomplishment-2025.jpg',
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: _PosterSlice(
            title: '2026 event feature',
            subtitle:
                'Official promotional material for the Powerdive swimming event in Puerto Princesa City.',
            imagePath: 'assets/aatappp/accomplishment-2026.jpg',
          ),
        ),
      ],
    );
  }
}

class _PosterSlice extends StatelessWidget {
  const _PosterSlice({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Image.asset(imagePath, fit: BoxFit.fitWidth),
        ),
        const SizedBox(height: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, height: 1.5, color: _muted),
        ),
      ],
    );
  }
}

class LeadershipSection extends StatelessWidget {
  const LeadershipSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return SectionShell(
      tone: SectionTone.light,
      contentAlignment: Alignment.topCenter,
      topPadding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          wide
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LeadershipRoster(
                        title: 'Officers 2024–2026',
                        entries: _officers,
                      ),
                    ),
                    SizedBox(width: 22),
                    Expanded(
                      child: _LeadershipRoster(
                        title: 'Board of Trustees 2024–2026',
                        entries: _trustees,
                      ),
                    ),
                    SizedBox(width: 22),
                    Expanded(child: _LeadershipSidePanel()),
                  ],
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PresidentSpotlight(),
                    SizedBox(height: 24),
                    _LeadershipRoster(
                      title: 'Officers 2024–2026',
                      entries: _officers,
                    ),
                    SizedBox(height: 24),
                    _LeadershipRoster(
                      title: 'Board of Trustees 2024–2026',
                      entries: _trustees,
                    ),
                    SizedBox(height: 24),
                    _LeadershipSidePanel(),
                  ],
                ),
        ],
      ),
    );
  }
}

class _PresidentSpotlight extends StatelessWidget {
  const _PresidentSpotlight();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRESIDENT',
            style: TextStyle(
              color: _accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'BRYAN JOHN DIZON',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 26,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Ala Amid B&B',
            style: TextStyle(fontSize: 16, color: _muted, height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _LeadershipRoster extends StatelessWidget {
  const _LeadershipRoster({required this.title, required this.entries});

  final String title;
  final List<LeadershipEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: _muted,
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in entries) _LeadershipEntryTile(entry: entry),
      ],
    );
  }
}

class _LeadershipEntryTile extends StatelessWidget {
  const _LeadershipEntryTile({required this.entry});

  final LeadershipEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.name,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w700,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.role.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: _accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.affiliation,
            style: const TextStyle(fontSize: 12, color: _muted, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _LeadershipSidePanel extends StatelessWidget {
  const _LeadershipSidePanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PresidentSpotlight(),
        SizedBox(height: 18),
        Text(
          'WORKING COMMITTEE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: _muted,
          ),
        ),
        SizedBox(height: 12),
        _CommitteeIndex(),
      ],
    );
  }
}

class _CommitteeIndex extends StatelessWidget {
  const _CommitteeIndex();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return Column(
      children: _committees
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == _committees.length - 1
                    ? (isMobile ? 24 : 8)
                    : 8,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 34,
                      child: Text(
                        '0${entry.key + 1}',
                        style: const TextStyle(
                          color: _accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.value.scope,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _muted,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Heads: ${entry.value.heads}',
                            style: const TextStyle(fontSize: 12, color: _ink),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class PartnersSection extends StatelessWidget {
  const PartnersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final baseBottomPadding = width >= 1200
        ? 72.0
        : width >= 900
        ? 56.0
        : 32.0;
    return SectionShell(
      tone: SectionTone.dark,
      bottomPadding: baseBottomPadding - 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Partners',
            style: TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              color: _accent,
            ),
          ),
          const SizedBox(height: 16),
          const _PartnerMarquee(),
          const SizedBox(height: 56),
          const _PartnersFooter(),
        ],
      ),
    );
  }
}

class _PartnersFooter extends StatelessWidget {
  const _PartnersFooter();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Column(
      crossAxisAlignment: wide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _accent.withValues(alpha: 0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: const _FooterBrandBlock(wide: true)),
                  const SizedBox(width: 56),
                  const _FooterColumn(
                    title: 'Sections',
                    lines: [
                      'About Us',
                      'Members',
                      'Programs',
                      'Events',
                      'Leadership',
                      'Partners',
                    ],
                  ),
                  const SizedBox(width: 56),
                  const _FooterColumn(
                    title: 'Contact',
                    lines: [
                      'secretariat.aatappp@gmail.com',
                      'Puerto Princesa, Palawan',
                    ],
                  ),
                ],
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _FooterBrandBlock()),
                  SizedBox(height: 28),
                  _FooterColumn(
                    title: 'Sections',
                    lines: [
                      'About Us',
                      'Members',
                      'Programs',
                      'Events',
                      'Leadership',
                      'Partners',
                    ],
                  ),
                  SizedBox(height: 26),
                  _FooterColumn(
                    title: 'Contact',
                    lines: [
                      'secretariat.aatappp@gmail.com',
                      'Puerto Princesa, Palawan',
                    ],
                  ),
                ],
              ),
        const SizedBox(height: 30),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
        const SizedBox(height: 18),
        wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '© 2026 AATAPPP',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.56),
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              )
            : Text(
                '© 2026 AATAPPP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.56),
                  fontSize: 12,
                ),
              ),
      ],
    );
  }
}

class _PartnerMarquee extends StatefulWidget {
  const _PartnerMarquee();

  @override
  State<_PartnerMarquee> createState() => _PartnerMarqueeState();
}

class _PartnerMarqueeState extends State<_PartnerMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _paths = [
    'assets/aatappp/partner-1.png',
    'assets/aatappp/partner-2.png',
    'assets/aatappp/partner-3.png',
    'assets/aatappp/partner-4.png',
    'assets/aatappp/partner-5.png',
    'assets/aatappp/partner-6.jpg',
    'assets/aatappp/partner-7.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final itemWidth = width >= 1200
        ? 214.0
        : width >= 900
        ? 188.0
        : 164.0;
    const spacing = 18.0;
    final trackWidth =
        (_paths.length * itemWidth) + ((_paths.length - 1) * spacing);
    final totalTrackWidth = (trackWidth * 2) + spacing;

    return ClipRect(
      child: SizedBox(
        width: double.infinity,
        height: 118,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = -(trackWidth * _controller.value);
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: totalTrackWidth,
            maxWidth: totalTrackWidth,
            child: SizedBox(
              width: totalTrackWidth,
              child: Row(
                children: [
                  for (var loop = 0; loop < 2; loop++) ...[
                    for (var i = 0; i < _paths.length; i++) ...[
                      SizedBox(
                        width: itemWidth,
                        child: _PartnerPanel(path: _paths[i]),
                      ),
                      if (!(loop == 1 && i == _paths.length - 1))
                        const SizedBox(width: spacing),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PartnerPanel extends StatelessWidget {
  const _PartnerPanel({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return _HoverBuilder(
      builder: (context, hovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 104,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.transparent),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: hovered ? 1 : 0.82,
            child: Center(child: Image.asset(path, fit: BoxFit.contain)),
          ),
        );
      },
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 54),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1420),
          child: Column(
            crossAxisAlignment: wide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Container(height: 1, color: _accent.withValues(alpha: 0.5)),
              const SizedBox(height: 34),
              wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _LogoLockup(
                                compact: false,
                                dark: true,
                                showSubtitle: false,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Association of Accredited Tourist Accommodations of Puerto Princesa, Palawan, Inc.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 72),
                        const _FooterColumn(
                          title: 'Navigate',
                          lines: [
                            'About Us',
                            'Members',
                            'Programs',
                            'Events',
                            'Leadership',
                            'Partners',
                          ],
                        ),
                        const SizedBox(width: 72),
                        const _FooterColumn(
                          title: 'Contact',
                          lines: [
                            'secretariat.aatappp@gmail.com',
                            'Puerto Princesa, Palawan',
                          ],
                        ),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _LogoLockup(
                          compact: false,
                          dark: true,
                          showSubtitle: false,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Association of Accredited Tourist Accommodations of Puerto Princesa, Palawan, Inc.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.9,
                          ),
                        ),
                        SizedBox(height: 30),
                        _FooterColumn(
                          title: 'Navigate',
                          centered: true,
                          lines: [
                            'About Us',
                            'Members',
                            'Programs',
                            'Events',
                            'Leadership',
                            'Partners',
                          ],
                        ),
                        SizedBox(height: 26),
                        _FooterColumn(
                          title: 'Contact',
                          centered: true,
                          lines: [
                            'secretariat.aatappp@gmail.com',
                            'Puerto Princesa, Palawan',
                          ],
                        ),
                      ],
                    ),
              const SizedBox(height: 34),
              wide
                  ? Row(
                      children: [
                        Text(
                          '© 2026 AATAPPP',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.58),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Accredited Hospitality in Puerto Princesa',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.42),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '© 2026 AATAPPP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.58),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Accredited Hospitality in Puerto Princesa',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.42),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterBrandBlock extends StatelessWidget {
  const _FooterBrandBlock({this.wide = false});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final centered = !wide;

    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        const _LogoLockup(compact: false, dark: true, showSubtitle: false),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 420 : 520),
          child: Text(
            'Association of Accredited Tourist Accommodations of Puerto Princesa, Palawan, Inc.',
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 14,
              height: 1.75,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            color: Colors.white.withValues(alpha: 0.02),
          ),
          child: Text(
            'secretariat.aatappp@gmail.com',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({
    required this.title,
    required this.lines,
    this.centered = false,
  });

  final String title;
  final List<String> lines;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.42),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 14),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              line,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HoverBuilder(
      builder: (context, hovered) {
        final color = active
            ? _accent
            : hovered
            ? Colors.white
            : Colors.white.withValues(alpha: 0.78);
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: active
                        ? _accent
                        : hovered
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.transparent,
                    width: active ? 2 : 1,
                  ),
                ),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: hovered ? 0.2 : 0,
                ),
                child: Text(label),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HoverBuilder extends StatefulWidget {
  const _HoverBuilder({required this.builder});

  final Widget Function(BuildContext context, bool hovered) builder;

  @override
  State<_HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<_HoverBuilder> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: widget.builder(context, _hovered),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: _ink,
              fontSize: MediaQuery.sizeOf(context).width >= 900 ? 48 : 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: const TextStyle(color: _muted, fontSize: 16, height: 1.8),
          ),
        ],
      ),
    );
  }
}

class _LogoLockup extends StatelessWidget {
  const _LogoLockup({
    required this.compact,
    required this.dark,
    this.showSubtitle = true,
  });

  final bool compact;
  final bool dark;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    final assetPath = dark
        ? 'assets/aatappp/branding/aatappp-white-text.png'
        : 'assets/aatappp/branding/aatappp-black-text.png';

    return Image.asset(
      assetPath,
      height: compact ? 40 : 106,
      fit: BoxFit.contain,
    );
  }
}

enum SectionTone { light, dark }

class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.child,
    required this.tone,
    this.contentAlignment = Alignment.center,
    this.topPadding,
    this.bottomPadding,
  });

  final Widget child;
  final SectionTone tone;
  final Alignment contentAlignment;
  final double? topPadding;
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final dark = tone == SectionTone.dark;
    final size = MediaQuery.sizeOf(context);
    final viewportHeight = size.height;
    final viewportWidth = size.width;
    final isMobile = viewportWidth < 760;
    final sectionMinHeight = viewportHeight > 0 ? viewportHeight : 980.0;
    final horizontalPadding = 24.0;
    final verticalPadding = viewportWidth >= 1200
        ? 72.0
        : viewportWidth >= 900
        ? 56.0
        : 32.0;
    final resolvedTopPadding = topPadding ?? verticalPadding;
    final resolvedBottomPadding = bottomPadding ?? verticalPadding;
    final contentWidth = viewportWidth >= 1000
        ? 1420.0
        : viewportWidth - (horizontalPadding * 2);

    return SizedBox(
      width: double.infinity,
      child: ColoredBox(
        color: dark ? Colors.black : _surface,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: isMobile ? 0 : sectionMinHeight,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              resolvedTopPadding,
              horizontalPadding,
              resolvedBottomPadding,
            ),
            child: Align(
              alignment: contentAlignment,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProgramItem {
  const ProgramItem(this.title, this.text);

  final String title;
  final String text;
}

class EventItem {
  const EventItem({
    required this.month,
    required this.day,
    required this.title,
    required this.venue,
    required this.description,
  });

  final String month;
  final String day;
  final String title;
  final String venue;
  final String description;
}

class LeadershipEntry {
  const LeadershipEntry(this.name, this.role, this.affiliation);

  final String name;
  final String role;
  final String affiliation;
}

class CommitteeEntry {
  const CommitteeEntry(this.title, this.scope, this.heads);

  final String title;
  final String scope;
  final String heads;
}

const _hotelsAndResorts = [
  'A&A Plaza Hotel',
  'Astoria Palawan',
  'Aziza Paradise Hotel',
  'Best Western Plus the Ivywall Hotel',
  'Citystate Asturias Hotel',
  'Costa Palawan Resort',
  'Daluyon Beach and Mountain Resort',
  'Empire Suites Hotel',
  'Fersal Hotel - Puerto Princesa',
  'Four Points by Sheraton Palawan',
  'Go Hotels Puerto Princesa',
  'Holiday Suites Puerto Princesa',
  'Microtel by Wyndham',
  'Palawan Uno Hotel',
  'Sotogrande Palawan Hotel',
  'Sunlight Guest Hotel Inc.',
  'The Dome Palawan',
  'The Funny Lion - Puerto Princesa',
  'Princesa Garden Island Resort',
  'Crown Hotel Palawan at Harbour Springs',
  'Hotel Centro',
];

const _mabuhayAccommodations = [
  'Ala Amid Bed & Breakfast',
  'Alvea Hotel - Puerto Princesa',
  'Angelic Mansion',
  'Bambu Suites',
  'Blue Lagoon Inn & Suites',
  'Cafemoto Lifestyle',
  'Canvass Boutique Hotel',
  'Casa Belina Tourist Inn',
  'Casa De Praxides Tourist Inn',
  'Casana Suites',
  "D' Beach Resort",
  'Diakopes Inn',
  'Dinah’s Tourist Inn',
  'Dolce Vita Hotel & Restaurant',
  'Elleis Place',
  'Escape Boutique Hotel',
  'Grande Vista Hotel',
  'Hotel Palacio',
  'KSK Serenity Resort',
  'Lokal Hut Bed and Breakfast',
  'Lola Itangs Pension House',
  'Orange Mangrove Pension House',
  'One Eight Residences Inn',
  'Puerto Pension Inn',
  'Rodolfo Royale Hotel',
  'Sandy Beach Hotel and Resort',
  'Sheridan Boutique Hotel',
  'Southwind Palawan',
  'Upgrace Inn',
  'Wanderlust Bed & Breakfast',
  'Whitebreeze Palawan Hotel',
];

const _programs = [
  ProgramItem(
    'Industry representation',
    'We represent the accommodation sector in the Accredited TESDA MIMAROPA Industry Board and in other institutional engagements in Puerto Princesa.',
  ),
  ProgramItem(
    'Tourism promotion',
    'AATAPPP represents Puerto Princesa in direct B2B events aligned with destination and accommodation promotion.',
  ),
  ProgramItem(
    'Security and business protection',
    'We maintain partnerships with the Armed Forces and local police to support crime prevention and business protection.',
  ),
  ProgramItem(
    'Member benefits',
    'We connect members to services, offers, and support programs through our partner and supplier network.',
  ),
  ProgramItem(
    'Training and development',
    'In-house and external training programs that support professional growth and member readiness.',
  ),
  ProgramItem(
    'Community support',
    'We extend community service and family support initiatives in Puerto Princesa whenever needed.',
  ),
];

const _plans = [
  'We expand the visibility of Puerto Princesa’s accredited accommodations in local and international markets, including ASEAN-facing opportunities.',
  'We grow new tourism markets for Palawan through digitalization.',
  'We strengthen incentive travel, conventions, and sports tourism.',
  'We coordinate closely with the local government unit to promote accredited accommodations in Puerto Princesa.',
];

const _missionThemePrimary = [
  'Partnerships with local and nationally recognized tourism organizations',
  'Assistance and training that increase accredited establishments',
  'Education and professional collaboration that address workforce concerns',
];

const _missionThemeSecondary = [
  'Government coordination for a business-friendly, safe, and sustainable city',
  'Projects that create positive impact for members and the wider community',
];

const _events = [
  EventItem(
    month: 'JAN',
    day: '10',
    title: '1st Powerdive Swimming Event',
    venue: 'RVM Sports Complex, Puerto Princesa',
    description:
        'The 2026 calendar positioned this event within the city’s sports tourism push.',
  ),
  EventItem(
    month: 'JAN',
    day: '22',
    title: '1st General Membership Meeting',
    venue: 'Best Western Ivy Wall',
    description:
        'Our 2026 calendar identified this as a key early-year membership gathering.',
  ),
  EventItem(
    month: 'FEB',
    day: '14',
    title: 'MOA Signing for TESDA Industry Board Renewal',
    venue: 'Venue details were marked TBA in the calendar',
    description:
        'This activity covered the renewal signing for the TESDA industry board.',
  ),
  EventItem(
    month: 'FEB',
    day: '29',
    title: 'Participation in “Love Affair with Nature” Tree Planting',
    venue: 'Venue details were marked TBA in the calendar',
    description:
        'Our calendar included this environmental activity as part of the year’s outreach.',
  ),
  EventItem(
    month: 'MAR',
    day: '7',
    title: 'MOA Signing with Farmers’ Associations',
    venue: 'Direct farm supplies initiative',
    description:
        'This partnership supported a direct farm supplies initiative.',
  ),
  EventItem(
    month: 'APR',
    day: '4-5',
    title: '1st Tourism Summit',
    venue:
        'In partnership with Puerto Princesa Chamber of Commerce Inc.; venue was listed as TBA',
    description:
        'Our 2026 calendar highlighted this as a major tourism-facing activity.',
  ),
  EventItem(
    month: 'APR',
    day: '20',
    title: '2nd AATAPPP General Membership Meeting',
    venue: 'Venue was to be announced',
    description:
        'This served as the follow-up general membership meeting on the 2026 calendar.',
  ),
];

const _officers = [
  LeadershipEntry('Bryan John Dizon', 'President', 'Ala Amid B&B'),
  LeadershipEntry(
    'Benhur Caballes',
    'VP for External Affairs',
    'Astoria Palawan',
  ),
  LeadershipEntry(
    'Ronnie Santa Ana',
    'Vice President for Hotels & Resorts',
    'Costa Palawan',
  ),
  LeadershipEntry(
    'Donald Keith Bognoson',
    'Vice President for Mabuhay Accom',
    'Hotel Palacio',
  ),
  LeadershipEntry('Jocelyn Villaos', 'Executive Secretary', 'Casa de Praxides'),
  LeadershipEntry('Meriden Wakefield', 'Treasurer', 'Elleis Pension'),
  LeadershipEntry(
    'Guenevere Villanueva',
    'Auditor / Public Relations Officer',
    'Upgrace Inn',
  ),
];

const _trustees = [
  LeadershipEntry('Lut De Guzman', 'Board of Trustees', 'A&A Plaza Hotel'),
  LeadershipEntry('Deborah Tan', 'Board of Trustees', 'Puerto Pension Inn'),
  LeadershipEntry('Dieyna Caber', 'Board of Trustees', 'Escape Boutique Hotel'),
  LeadershipEntry(
    'Tess Baylosis',
    'Board of Trustees',
    'The Dome Hotels & Resorts',
  ),
  LeadershipEntry(
    'Diana Tamayo',
    'Board of Trustees',
    'Best Western Plus the Ivy Wall Hotel',
  ),
];

const _committees = [
  CommitteeEntry(
    'Internal Affairs',
    'Association affairs, membership, and special concerns.',
    'Tess Baylosis, Diana Tamayo',
  ),
  CommitteeEntry(
    'Events & Linkages',
    'Partnerships, promotions, and events.',
    'Benhur Caballes, Ronnie Santa Ana, Donald Bognoson',
  ),
  CommitteeEntry(
    'Public Affairs',
    'Internal and external communications.',
    'Bryan John Dizon, Debbie Tan',
  ),
  CommitteeEntry(
    'External Affairs',
    'Government liaison and coordination.',
    'Jocelyn Villaos, Mary Den Wakefield, Luz De Guzman',
  ),
  CommitteeEntry(
    'Education & Training',
    'Implementation of professional programs.',
    'Guen Villanueva, Dieyna Caber',
  ),
];
