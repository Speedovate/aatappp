import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'member_logo_assets.dart';

void main() {
  runApp(const AatapppWebsiteApp());
}

const _accent = Color(0xFF89D500);
const _surface = Color(0xFFF6F6F1);
const _ink = Color(0xFF111111);
const _muted = Color(0xFF666666);
const _snapViewportInset = 96.0;
const _partnerPaths = [
  'assets/aatappp/partner-1.jpg',
  'assets/aatappp/partner-2.png',
  'assets/aatappp/partner-3.png',
  'assets/aatappp/partner-4.png',
  'assets/aatappp/partner-5.png',
  'assets/aatappp/partner-6.jpg',
  'assets/aatappp/partner-7.jpg',
];

final Map<String, MemberLogoAsset> _memberLogoAssetByName = {
  for (final asset in memberLogoAssets) ...{
    _normalizeMemberName(asset.associationName): asset,
    if (asset.officialBrandName != null)
      _normalizeMemberName(asset.officialBrandName!): asset,
  },
};

double _splitAvailableWidth(double viewportWidth) => viewportWidth - 48;

double _splitGap(double viewportWidth) =>
    (_splitAvailableWidth(viewportWidth) * 0.045).clamp(40.0, 112.0);

double _splitRightColumnWidth(double viewportWidth) =>
    (_splitAvailableWidth(viewportWidth) * 0.31).clamp(420.0, 760.0);

double _splitLeftColumnWidth(double viewportWidth) =>
    _splitAvailableWidth(viewportWidth) -
    _splitGap(viewportWidth) -
    _splitRightColumnWidth(viewportWidth);

bool _shouldUseSplitLayout(double viewportWidth) =>
    viewportWidth >= 760 &&
    viewportWidth > 1240 &&
    _splitLeftColumnWidth(viewportWidth) >= 560;

String _normalizeMemberName(String value) {
  return value
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll(RegExp(r'\bpuerto\b'), ' ')
      .replaceAll(RegExp(r'\bprincesa\b'), ' ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

String _memberInitials(String value) {
  const stopwords = {
    'and',
    'the',
    'of',
    'by',
    'inc',
    'at',
    'hotel',
    'resort',
    'resorts',
    'suite',
    'suites',
    'inn',
    'house',
    'bed',
    'breakfast',
    'tourist',
    'pension',
    'guest',
    'plus',
  };

  final words = _normalizeMemberName(
    value,
  ).split(' ').where((word) => word.isNotEmpty).toList();
  final preferred = words.where((word) => !stopwords.contains(word)).toList();
  final source = preferred.isNotEmpty ? preferred : words;

  if (source.isEmpty) return '?';
  if (source.length == 1) return source.first.substring(0, 1).toUpperCase();

  return (source[0].substring(0, 1) + source[1].substring(0, 1)).toUpperCase();
}

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
      home: const SelectionArea(child: HomePage()),
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
  Size? _lastViewportSize;

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
    final viewportSize = MediaQuery.sizeOf(context);
    if (_lastViewportSize != viewportSize) {
      debugPrint(
        '[viewport] width=${viewportSize.width.toStringAsFixed(1)}px '
        'height=${viewportSize.height.toStringAsFixed(1)}px '
        'previous=${_lastViewportSize == null ? 'none' : '${_lastViewportSize!.width.toStringAsFixed(1)}x${_lastViewportSize!.height.toStringAsFixed(1)}'}',
      );
      _lastViewportSize = viewportSize;
    }

    final width = viewportSize.width;
    final isDesktop = width >= 1040;
    final heroShouldSplit = _shouldUseSplitLayout(width);
    final shouldSnap = isDesktop && heroShouldSplit;
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
              if (shouldSnap &&
                  event is PointerScrollEvent &&
                  event.scrollDelta.dy.abs() > 0) {
                _snapToAdjacentSection(event.scrollDelta.dy > 0 ? 1 : -1);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: shouldSnap
                  ? (_) {
                      _dragDeltaY = 0;
                    }
                  : null,
              onVerticalDragUpdate: shouldSnap
                  ? (details) {
                      _dragDeltaY += details.primaryDelta ?? 0;
                    }
                  : null,
              onVerticalDragEnd: shouldSnap
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
                physics: shouldSnap
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
  static String? _lastHeroDebugSignature;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final isTablet = width >= 760;
    final display = Theme.of(context).textTheme.displayLarge!;
    final stackedHeroStyle = display.copyWith(
      fontSize: isTablet ? 50 : 38,
      height: 0.94,
    );
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final availableWidth = _splitAvailableWidth(width);
        final gap = _splitGap(width);
        final rightColumnWidth = _splitRightColumnWidth(width);
        final leftColumnWidth = availableWidth - gap - rightColumnWidth;
        final shouldSplit = _shouldUseSplitLayout(width);
        final heroDebugSignature =
            'width=${availableWidth.toStringAsFixed(1)} '
            'height=${(outerConstraints.maxHeight.isFinite ? outerConstraints.maxHeight : height).toStringAsFixed(1)} '
            'left=${leftColumnWidth.toStringAsFixed(1)} '
            'right=${rightColumnWidth.toStringAsFixed(1)} '
            'split=$shouldSplit';
        if (_lastHeroDebugSignature != heroDebugSignature) {
          debugPrint('[hero-layout] $heroDebugSignature');
          _lastHeroDebugSignature = heroDebugSignature;
        }

        if (shouldSplit) {
          final splitHeroStyle = display.copyWith(
            fontSize: (availableWidth * 0.048).clamp(56.0, 60.0),
            height: 0.94,
          );
          final splitHeroHeight = height > 0 ? height : 980.0;

          return SizedBox(
            height: splitHeroHeight,
            child: ColoredBox(
              color: Colors.black,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _HeroBackgroundOrbs(isTablet: isTablet),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 132, 24, 84),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 11,
                              child: _HeroCopy(
                                heroStyle: splitHeroStyle,
                                onPrimaryTap: onPrimaryTap,
                                bodyMaxWidth: leftColumnWidth * 0.82,
                              ),
                            ),
                            SizedBox(width: gap),
                            SizedBox(
                              width: rightColumnWidth,
                              child: const _HeroRightColumn(),
                            ),
                          ],
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

        return ColoredBox(
          color: Colors.black,
          child: Stack(
            children: [
              Positioned.fill(child: _HeroBackgroundOrbs(isTablet: isTablet)),
              Padding(
                padding: EdgeInsets.fromLTRB(24, isTablet ? 132 : 112, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HeroCopy(
                      heroStyle: stackedHeroStyle,
                      onPrimaryTap: onPrimaryTap,
                      bodyMaxWidth: availableWidth,
                    ),
                    const SizedBox(height: 28),
                    const _HeroHighlight(),
                    const SizedBox(height: 24),
                    const _HeroStatsRail(),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: isTablet ? 120 : 48,
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
        );
      },
    );
  }
}

class _HeroBackgroundOrbs extends StatelessWidget {
  const _HeroBackgroundOrbs({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            right: isTablet ? -120 : -90,
            top: isTablet ? 140 : 210,
            child: Container(
              width: isTablet ? 520 : 320,
              height: isTablet ? 520 : 320,
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
          Positioned(
            left: -160,
            bottom: -150,
            child: Container(
              width: isTablet ? 500 : 280,
              height: isTablet ? 500 : 280,
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
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.heroStyle,
    required this.onPrimaryTap,
    this.bodyMaxWidth,
  });

  final TextStyle heroStyle;
  final VoidCallback onPrimaryTap;
  final double? bodyMaxWidth;

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
          constraints: BoxConstraints(
            maxWidth: bodyMaxWidth ?? double.infinity,
          ),
          child: Text(
            'We set the standard for accredited tourist accommodations through leadership, accreditation, coordination, and member growth across Puerto Princesa and Palawan.',
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              color: Color(0xFFD7D7D7),
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = isMobile || constraints.maxWidth < 420;
            final horizontalPadding = compact ? 10.0 : 22.0;
            final verticalPadding = compact ? 14.0 : 16.0;
            final fontSize = compact ? 13.0 : 14.0;

            return Wrap(
              alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    final state = context
                        .findAncestorStateOfType<_HomePageState>();
                    state?._scrollTo('About');
                  },
                  child: Text(
                    'About',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: onPrimaryTap,
                  child: Text(
                    'Members',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: _ink,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    final state = context
                        .findAncestorStateOfType<_HomePageState>();
                    state?._scrollTo('Partners');
                  },
                  child: Text(
                    'Join Us',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _HeroBlankCard(bodyMaxWidth: bodyMaxWidth),
      ],
    );
  }
}

class _HeroBlankCard extends StatelessWidget {
  const _HeroBlankCard({this.bodyMaxWidth});

  final double? bodyMaxWidth;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: bodyMaxWidth ?? double.infinity),
      child: Container(
        width: double.infinity,
        height: isMobile ? 88 : 104,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(1000),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: const ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(1000)),
          child: _HeroPartnerStrip(),
        ),
      ),
    );
  }
}

class _HeroPartnerStrip extends StatefulWidget {
  const _HeroPartnerStrip();

  @override
  State<_HeroPartnerStrip> createState() => _HeroPartnerStripState();
}

class _HeroPartnerStripState extends State<_HeroPartnerStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
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
    final itemSize = width < 760 ? 54.0 : 64.0;
    const spacing = 12.0;
    final trackWidth =
        (_partnerPaths.length * itemSize) +
        ((_partnerPaths.length - 1) * spacing);
    final cycleWidth = trackWidth + spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final repeatCount = math.max(
          3,
          ((constraints.maxWidth / cycleWidth).ceil()) + 2,
        );
        final totalTrackWidth = (repeatCount * cycleWidth) - spacing;
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = -(cycleWidth * _controller.value) - cycleWidth;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: totalTrackWidth,
              maxWidth: totalTrackWidth,
              child: SizedBox(
                width: totalTrackWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var loop = 0; loop < repeatCount; loop++) ...[
                      for (var i = 0; i < _partnerPaths.length; i++) ...[
                        SizedBox(
                          width: itemSize,
                          height: itemSize,
                          child: _PartnerPanel(
                            path: _partnerPaths[i],
                            size: itemSize,
                          ),
                        ),
                        if (!(loop == repeatCount - 1 &&
                            i == _partnerPaths.length - 1))
                          const SizedBox(width: spacing),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our network brings together accredited tourist accommodations across Puerto Princesa in one clear, credible association platform.',
            style: TextStyle(fontSize: 14, height: 1.6, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: _accent.withValues(alpha: 0.7)),
          const SizedBox(height: 12),
          const _HeroHighlightBody(),
          const SizedBox(height: 4),
          Text(
            'We speak for accredited hospitality with a clear institutional voice.',
            style: TextStyle(fontSize: 12, height: 1.5, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _HeroHighlightBody extends StatelessWidget {
  const _HeroHighlightBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Core Focus',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        _HeroMiniBullet('We represent accredited tourist accommodations'),
        _HeroMiniBullet('We drive partnerships, training, and co-opetition'),
        _HeroMiniBullet('We uphold standards and tourism growth'),
      ],
    );
  }
}

class _HeroMiniBullet extends StatelessWidget {
  const _HeroMiniBullet(this.text);

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
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.white,
              ),
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
          final compact = constraints.maxWidth < 420;
          final gap = compact ? 8.0 : 16.0;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: _StatChip(
                    title: 'Members',
                    value: '50+',
                    expand: true,
                    compact: compact,
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  flex: 4,
                  child: _StatChip(
                    title: 'Officers & BODs',
                    value: '12',
                    expand: true,
                    compact: compact,
                  ),
                ),
                SizedBox(width: gap),
                Expanded(
                  flex: 4,
                  child: _StatChip(
                    title: 'Working Commitee',
                    value: '12',
                    expand: true,
                    compact: compact,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.title,
    required this.value,
    this.expand = false,
    this.compact = false,
  });

  final String title;
  final String value;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: expand ? double.infinity : null,
      height: expand ? double.infinity : null,
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 20,
        compact ? 14 : 18,
        compact ? 14 : 20,
        compact ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 24 : 32,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          Container(
            width: expand ? double.infinity : 92,
            height: 1,
            color: _accent.withValues(alpha: 0.7),
          ),
          SizedBox(height: compact ? 6 : 8),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: compact ? 11 : 13,
                  height: 1.3,
                ),
              ),
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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = _shouldUseSplitLayout(width);
    final splitGap = _splitGap(width);
    final rightColumnWidth = _splitRightColumnWidth(width);
    final sectionTopPadding = isDesktop ? 132.0 : 24.0;
    final sectionBottomPadding = isDesktop ? 84.0 : 24.0;
    return SectionShell(
      tone: SectionTone.light,
      orbStyle: SectionOrbStyle.strong,
      contentAlignment: isDesktop ? const Alignment(0, -0.2) : Alignment.center,
      topPadding: sectionTopPadding,
      bottomPadding: sectionBottomPadding,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: _AboutCopy()),
                  SizedBox(width: splitGap),
                  SizedBox(width: rightColumnWidth, child: const _AboutCard()),
                ],
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_AboutCopy(), SizedBox(height: 24), _AboutCard()],
              ),
      ),
    );
  }
}

class _AboutCopy extends StatelessWidget {
  const _AboutCopy();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width >= 1200 ? 52.0 : (width >= 900 ? 46.0 : 36.0);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ABOUT US',
            style: TextStyle(
              color: _accent,
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'We lead accredited accommodations with one voice.',
            style: TextStyle(
              color: _ink,
              fontSize: titleSize,
              height: 1.04,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: const Text(
              'AATAPPP is the official association of accredited tourist accommodations in Puerto Princesa, Palawan. We lead industry coordination, professional standards, and member growth across the local hospitality sector.',
              style: TextStyle(color: _muted, fontSize: 16, height: 1.8),
            ),
          ),
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
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
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
            title: 'Accreditation Growth',
            text:
                'We expand accreditation through member assistance, training, and industry guidance.',
          ),
          _ValueStrip(
            title: 'Business Support',
            text:
                'We strengthen collaboration that drives shared business growth.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ValueStrip extends StatelessWidget {
  const _ValueStrip({
    required this.title,
    required this.text,
    this.isLast = false,
  });

  final String title;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.65,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 18),
            Container(height: 1, color: _accent.withValues(alpha: 0.7)),
          ],
        ],
      ),
    );
  }
}

class MissionVisionSection extends StatelessWidget {
  const MissionVisionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = _shouldUseSplitLayout(width);
    final splitGap = _splitGap(width);
    final rightColumnWidth = _splitRightColumnWidth(width);
    final sectionTopPadding = isDesktop ? 132.0 : 24.0;
    final sectionBottomPadding = isDesktop ? 84.0 : 24.0;
    return SectionShell(
      tone: SectionTone.dark,
      orbStyle: SectionOrbStyle.medium,
      contentAlignment: isDesktop ? const Alignment(0, -0.2) : Alignment.center,
      topPadding: sectionTopPadding,
      bottomPadding: sectionBottomPadding,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: isDesktop
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
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
                    SizedBox(width: splitGap),
                    SizedBox(
                      width: rightColumnWidth,
                      child: const _MissionThemesCard(
                        title: 'Mission Themes',
                        items: _missionThemePrimary,
                        secondaryTitle: 'Focus Areas',
                        secondaryItems: _missionThemeSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MISSION & VISION',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                    ),
                  ),
                  SizedBox(height: 24),
                  _StatementCard(
                    title: 'Mission',
                    text:
                        'We build strong tourism partnerships, expand accreditation through assistance and training, support education and workforce readiness, coordinate with government for a safe and sustainable business environment, and create meaningful impact for members and the wider community.',
                  ),
                  SizedBox(height: 24),
                  _StatementCard(
                    title: 'Vision',
                    text:
                        'To be the premier organization in Puerto Princesa, Palawan, dedicated to promoting professionalism and high standards in accommodation services, fostering a spirit of co-opetition where members collaborate, uplift one another, and collectively achieve higher levels of excellence in business operations.',
                  ),
                  SizedBox(height: 24),
                  _MissionThemesCard(
                    title: 'Mission Themes',
                    items: _missionThemePrimary,
                  ),
                  SizedBox(height: 24),
                  _MissionThemesCard(
                    title: 'Focus Areas',
                    items: _missionThemeSecondary,
                  ),
                ],
              ),
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
    required this.items,
    this.secondaryTitle,
    this.secondaryItems,
  });

  final String title;
  final List<String> items;
  final String? secondaryTitle;
  final List<String>? secondaryItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items) _HeroMiniBullet(item),
          if (secondaryTitle != null && secondaryItems != null) ...[
            const SizedBox(height: 8),
            Container(height: 1, color: _accent.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(
              secondaryTitle!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            for (final item in secondaryItems!) _HeroMiniBullet(item),
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
      orbStyle: SectionOrbStyle.strong,
      contentAlignment: Alignment.topCenter,
      topPadding: 24,
      bottomPadding: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OUR MEMBERS',
              style: TextStyle(
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: _accent,
              ),
            ),
            const SizedBox(height: 24),
            isDesktop
                ? const IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _MemberBand(
                            title: 'Hotels & Resorts',
                            dark: true,
                            members: _hotelsAndResorts,
                            fillHeight: true,
                          ),
                        ),
                        SizedBox(width: 18),
                        Expanded(
                          child: _MemberBand(
                            title: 'Mabuhay Accommodations',
                            dark: false,
                            members: _mabuhayAccommodations,
                            fillHeight: true,
                          ),
                        ),
                      ],
                    ),
                  )
                : const Column(
                    children: [
                      _MemberBand(
                        title: 'Hotels & Resorts',
                        dark: true,
                        members: _hotelsAndResorts,
                      ),
                      SizedBox(height: 24),
                      _MemberBand(
                        title: 'Mabuhay Accommodations',
                        dark: false,
                        members: _mabuhayAccommodations,
                      ),
                    ],
                  ),
            if (isDesktop) const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _MemberBand extends StatelessWidget {
  const _MemberBand({
    required this.title,
    required this.dark,
    required this.members,
    this.fillHeight = false,
  });

  final String title;
  final bool dark;
  final List<String> members;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: fillHeight ? double.infinity : null,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 1,
            color: _accent.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 9,
            runSpacing: 7,
            children: members
                .map(
                  (member) => ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: _MemberPillContent(member: member),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MemberPillContent extends StatelessWidget {
  const _MemberPillContent({required this.member});

  final String member;

  @override
  Widget build(BuildContext context) {
    final logoAsset = _memberLogoAssetByName[_normalizeMemberName(member)];

    return Container(
      padding: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MemberPillLogo(member: member, logoAsset: logoAsset),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              member,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberPillLogo extends StatelessWidget {
  const _MemberPillLogo({required this.member, required this.logoAsset});

  final String member;
  final MemberLogoAsset? logoAsset;

  @override
  Widget build(BuildContext context) {
    final assetPath = logoAsset?.assetPath;
    final initials = _memberInitials(member);
    final useDarkLogoSurface =
        assetPath != null &&
        (assetPath.endsWith('.webp') || assetPath.contains('funny-lion'));

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: useDarkLogoSurface
            ? Colors.black.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.96),
      ),
      child: assetPath != null
          ? ClipOval(
              child: SizedBox.expand(
                child: Image.asset(
                  assetPath,
                  width: 30,
                  height: 30,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return _MemberPillInitials(initials: initials);
                  },
                ),
              ),
            )
          : _MemberPillInitials(initials: initials),
    );
  }
}

class _MemberPillInitials extends StatelessWidget {
  const _MemberPillInitials({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          initials,
          style: const TextStyle(
            color: _ink,
            fontSize: 10,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
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
      orbStyle: SectionOrbStyle.strong,
      contentAlignment: Alignment.topCenter,
      topPadding: 24,
      bottomPadding: wide ? null : 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (!wide) {
                  return Wrap(
                    spacing: 22,
                    runSpacing: 22,
                    children: _programs
                        .asMap()
                        .entries
                        .map(
                          (entry) => SizedBox(
                            width: constraints.maxWidth,
                            child: _ProgramCard(
                              index: '0${entry.key + 1}',
                              title: entry.value.title,
                              text: entry.value.text,
                            ),
                          ),
                        )
                        .toList(),
                  );
                }

                const columns = 3;
                final cardWidth = (constraints.maxWidth - 44) / columns;
                final rows = <Widget>[];

                for (
                  var start = 0;
                  start < _programs.length;
                  start += columns
                ) {
                  final end = math.min(start + columns, _programs.length);
                  final slice = _programs.sublist(start, end);
                  rows.add(
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < slice.length; i++) ...[
                            SizedBox(
                              width: cardWidth,
                              child: _ProgramCard(
                                index: '0${start + i + 1}',
                                title: slice[i].title,
                                text: slice[i].text,
                              ),
                            ),
                            if (i != slice.length - 1)
                              const SizedBox(width: 22),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      rows[i],
                      if (i != rows.length - 1) const SizedBox(height: 22),
                    ],
                  ],
                );
              },
            ),
            SizedBox(height: wide ? 18 : 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2026 → BEYOND',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontSize: MediaQuery.sizeOf(context).width >= 900
                          ? 42
                          : 34,
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
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Container(width: double.infinity, height: 1, color: _accent),
              ],
            ),
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
    return Row(
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
      orbStyle: SectionOrbStyle.faint,
      contentAlignment: Alignment.topCenter,
      topPadding: 24,
      bottomPadding: wide ? null : 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: wide
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EVENTS',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: _accent,
                    ),
                  ),
                  SizedBox(height: 24),
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
                    'EVENTS',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: _accent,
                    ),
                  ),
                  SizedBox(height: 24),
                  _PosterStack(),
                  SizedBox(height: 28),
                  _EventTimeline(),
                ],
              ),
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
      children: _events.asMap().entries.map((entry) {
        final isLast = entry.key == _events.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: _EventCard(event: entry.value),
        );
      }).toList(),
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
            title: '10th Anniversary & Members Appreciation Night',
            imagePath: 'assets/aatappp/accomplishment-2025.jpg',
          ),
        ),
        SizedBox(width: 18),
        Expanded(
          child: _PosterSlice(
            title: '1st Powerdive Class ABCD Motivational Swimming Event',
            imagePath: 'assets/aatappp/accomplishment-2026.jpg',
          ),
        ),
      ],
    );
  }
}

class _PosterSlice extends StatelessWidget {
  const _PosterSlice({required this.title, required this.imagePath});

  final String title;
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
      orbStyle: SectionOrbStyle.faint,
      contentAlignment: Alignment.topCenter,
      topPadding: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
          SizedBox(height: 2),
          Text(
            'Ala Amid Bed & Breakfast',
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
    return Column(
      children: _committees
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == _committees.length - 1 ? 0 : 8,
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
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;
    final isDesktop = width >= 1040;
    final isVertical = height > width;
    final usePinnedViewport = isDesktop && !isVertical;
    final sectionTopPadding = width >= 1200
        ? 72.0
        : width >= 900
        ? 56.0
        : 32.0;
    final sectionBottomPadding = 0.0;
    final visibleSectionHeight = math.max(0.0, height - _snapViewportInset);
    final contentHeight = math.max(
      0.0,
      visibleSectionHeight - sectionTopPadding - sectionBottomPadding,
    );
    return SectionShell(
      tone: SectionTone.dark,
      orbStyle: SectionOrbStyle.subtle,
      contentAlignment: Alignment.topCenter,
      topPadding: sectionTopPadding,
      bottomPadding: sectionBottomPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canPinFooter = usePinnedViewport && contentHeight > 0;
          final content = canPinFooter
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'OUR PARTNERS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 40 : 30,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          color: _accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Expanded(
                      child: Align(
                        alignment: Alignment(0, -0.35),
                        child: _PartnerMarquee(),
                      ),
                    ),
                    const _PartnersFooter(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'OUR PARTNERS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 40 : 30,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          color: _accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 44),
                    const _PartnerMarquee(),
                    const SizedBox(height: 24),
                    const _PartnersFooter(),
                  ],
                );

          if (!canPinFooter) {
            return content;
          }

          return SizedBox(height: contentHeight, child: content);
        },
      ),
    );
  }
}

class _PartnersFooter extends StatelessWidget {
  const _PartnersFooter();

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final wide = viewportWidth >= 900;
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
                _accent.withValues(alpha: 0.72),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          color: Colors.black,
          child: Column(
            crossAxisAlignment: wide
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: const Text(
                              '© 2026 AATAPPP All Rights Reserved.',
                              style: _footerDesktopItemStyle,
                            ),
                          ),
                          const Expanded(
                            flex: 7,
                            child: Align(
                              alignment: Alignment.center,
                              child: _FooterDesktopSections(),
                            ),
                          ),
                          const Expanded(
                            flex: 5,
                            child: _FooterDesktopContact(),
                          ),
                        ],
                      )
                    : const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            lines: ['secretariat.aatappp@gmail.com'],
                          ),
                        ],
                      ),
              ),
              if (!wide) ...[
                const SizedBox(height: 24),
                Text(
                  '© 2026 AATAPPP All Rights Reserved.',
                  textAlign: TextAlign.center,
                  style: _footerDesktopItemStyle,
                ),
              ],
              const SizedBox(height: 24),
            ],
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
    const itemSize = 200.0;
    const spacing = 18.0;
    final trackWidth =
        (_partnerPaths.length * itemSize) +
        ((_partnerPaths.length - 1) * spacing);
    final cycleWidth = trackWidth + spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final repeatCount = math.max(
          3,
          ((constraints.maxWidth / cycleWidth).ceil()) + 2,
        );
        final totalTrackWidth = (repeatCount * cycleWidth) - spacing;

        return ClipRect(
          child: SizedBox(
            width: double.infinity,
            height: itemSize,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final offset = -(cycleWidth * _controller.value) - cycleWidth;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: totalTrackWidth,
                maxWidth: totalTrackWidth,
                child: SizedBox(
                  width: totalTrackWidth,
                  child: Row(
                    children: [
                      for (var loop = 0; loop < repeatCount; loop++) ...[
                        for (var i = 0; i < _partnerPaths.length; i++) ...[
                          SizedBox(
                            width: itemSize,
                            child: _PartnerPanel(
                              path: _partnerPaths[i],
                              size: itemSize,
                            ),
                          ),
                          if (!(loop == repeatCount - 1 &&
                              i == _partnerPaths.length - 1))
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
      },
    );
  }
}

class _PartnerPanel extends StatelessWidget {
  const _PartnerPanel({required this.path, required this.size});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _HoverBuilder(
      builder: (context, hovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: ClipOval(
            child: SizedBox.expand(
              child: Image.asset(
                path,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FooterDesktopSections extends StatelessWidget {
  const _FooterDesktopSections();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: Alignment.center,
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FooterSectionLink(label: 'About Us', target: 'About'),
          const SizedBox(width: 18),
          _FooterSectionLink(label: 'Members', target: 'Members'),
          const SizedBox(width: 18),
          _FooterSectionLink(label: 'Programs', target: 'Programs'),
          const SizedBox(width: 18),
          _FooterSectionLink(label: 'Events', target: 'Events'),
          const SizedBox(width: 18),
          _FooterSectionLink(label: 'Leadership', target: 'Leadership'),
          const SizedBox(width: 18),
          _FooterSectionLink(label: 'Partners', target: 'Partners'),
        ],
      ),
    );
  }
}

class _FooterDesktopContact extends StatelessWidget {
  const _FooterDesktopContact();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerRight,
      child: FittedBox(
        alignment: Alignment.centerRight,
        fit: BoxFit.scaleDown,
        child: Text(
          'secretariat.aatappp@gmail.com',
          textAlign: TextAlign.right,
          style: _footerDesktopItemStyle,
        ),
      ),
    );
  }
}

class _FooterSectionLink extends StatefulWidget {
  const _FooterSectionLink({required this.label, required this.target});

  final String label;
  final String target;

  @override
  State<_FooterSectionLink> createState() => _FooterSectionLinkState();
}

class _FooterSectionLinkState extends State<_FooterSectionLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final state = context.findAncestorStateOfType<_HomePageState>();
          state?._scrollTo(widget.target);
        },
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: _footerDesktopItemStyle.copyWith(
            color: _hovered ? _accent : Colors.white,
            decoration: _hovered ? TextDecoration.underline : null,
            decorationColor: _hovered ? _accent : Colors.white,
          ),
          child: Text(widget.label, textAlign: TextAlign.right),
        ),
      ),
    );
  }
}

const _footerDesktopItemStyle = TextStyle(
  color: Colors.white,
  fontSize: 14,
  height: 1.55,
);

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
                          '© 2026 AATAPPP. All rights reserved.',
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
                          '© 2026 AATAPPP. All rights reserved.',
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
        final color = active ? _accent : Colors.white;
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

enum SectionOrbStyle { none, faint, subtle, medium, strong }

class SectionShell extends StatelessWidget {
  const SectionShell({
    super.key,
    required this.child,
    required this.tone,
    this.orbStyle = SectionOrbStyle.subtle,
    this.contentAlignment = Alignment.center,
    this.topPadding,
    this.bottomPadding,
  });

  final Widget child;
  final SectionTone tone;
  final SectionOrbStyle orbStyle;
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
    final isVertical = viewportHeight > viewportWidth;
    final useViewportHeight = viewportWidth >= 1040 && !isVertical;
    final sectionMinHeight = viewportHeight > 0 ? viewportHeight : 980.0;
    final snappedVisibleHeight = math.max(
      0.0,
      sectionMinHeight - _snapViewportInset,
    );
    final horizontalPadding = 0.0;
    final verticalPadding = isMobile
        ? 24.0
        : viewportWidth >= 1200
        ? 72.0
        : viewportWidth >= 900
        ? 56.0
        : 32.0;
    final resolvedTopPadding = topPadding ?? verticalPadding;
    final resolvedBottomPadding = bottomPadding ?? verticalPadding;
    final contentWidth = viewportWidth - (horizontalPadding * 2);

    return SizedBox(
      width: double.infinity,
      child: ColoredBox(
        color: dark ? Colors.black : _surface,
        child: Stack(
          children: [
            Positioned.fill(
              child: _SectionBackgroundOrbs(
                dark: dark,
                compact: isMobile,
                style: orbStyle,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: useViewportHeight ? snappedVisibleHeight : 0,
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
          ],
        ),
      ),
    );
  }
}

class _SectionBackgroundOrbs extends StatelessWidget {
  const _SectionBackgroundOrbs({
    required this.dark,
    required this.compact,
    required this.style,
  });

  final bool dark;
  final bool compact;
  final SectionOrbStyle style;

  @override
  Widget build(BuildContext context) {
    final intensity = switch (style) {
      SectionOrbStyle.none => 0.0,
      SectionOrbStyle.faint => 0.45,
      SectionOrbStyle.subtle => 0.75,
      SectionOrbStyle.medium => 1.0,
      SectionOrbStyle.strong => 1.35,
    };
    if (intensity == 0) {
      return const SizedBox.shrink();
    }

    final baseAlpha = (dark ? 0.035 : 0.05) * intensity;
    final glowAlpha = (dark ? 0.05 : 0.035) * intensity;
    final largeSize = compact ? 320.0 : 520.0;
    final mediumSize = compact ? 280.0 : 500.0;
    final rightTopRight = compact ? -120.0 : -150.0;
    final rightTopTop = compact ? 128.0 : 48.0;
    const leftBottomLeft = -160.0;
    final leftBottomBottom = compact ? -120.0 : -150.0;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            right: rightTopRight,
            top: rightTopTop,
            child: Container(
              width: largeSize,
              height: largeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: baseAlpha),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: glowAlpha),
                    blurRadius: compact ? 110 : 160,
                    spreadRadius: compact ? 8 : 14,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: leftBottomLeft,
            bottom: leftBottomBottom,
            child: Container(
              width: mediumSize,
              height: mediumSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: baseAlpha * 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: glowAlpha * 1.35),
                    blurRadius: 180,
                    spreadRadius: compact ? 18 : 28,
                  ),
                ],
              ),
            ),
          ),
        ],
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
  'Fersal Hotel',
  'Four Points by Sheraton Palawan',
  'Go Hotels',
  'Holiday Suites',
  'Microtel by Wyndham',
  'Palawan Uno Hotel',
  'Sotogrande Palawan Hotel',
  'Sunlight Guest Hotel Inc.',
  'The Dome Palawan',
  'The Funny Lion',
  'Princesa Garden Island Resort',
  'Crown Hotel Palawan at Harbour Springs',
  'Hotel Centro',
];

const _mabuhayAccommodations = [
  'Ala Amid Bed & Breakfast',
  'Alvea Hotel',
  'Angelic Mansion',
  'Bambu Suites',
  'Blue Lagoon Inn & Suites',
  'Cafemoto Lifestyle',
  'Canvas Boutique Hotel',
  'Casa Belina Tourist Inn',
  'Casa De Praxides Tourist Inn',
  'Casañas Suites',
  "D' Beach Resort",
  'Diakopes Inn',
  'Dinah’s Tourist Inn',
  'Dolce Vita Hotel & Restaurant',
  'Elleis Place',
  'Escape Boutique Hotel',
  'Grande Vista Hotel',
  'Hotel Palacio',
  'KSK Serenity Resort',
  'Lokal Hut Bed & Breakfast',
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
  'We coordinate closely with the local government unit to promote accredited accommodations in Puerto Princesa.',
  'We strengthen incentive travel, conventions, and sports tourism.',
  'We grow new tourism markets for Palawan through digitalization.',
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
  LeadershipEntry('Bryan John Dizon', 'President', 'Ala Amid Bed & Breakfast'),
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
