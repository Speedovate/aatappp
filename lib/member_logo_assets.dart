import 'package:flutter/material.dart';

class MemberLogoAsset {
  final String associationName;
  final String? officialBrandName;
  final String category;
  final String type;
  final String? officialUrl;
  final String? logoSourceUrl;
  final String? assetPath;
  final String verificationStatus;
  final String? notes;

  const MemberLogoAsset({
    required this.associationName,
    this.officialBrandName,
    required this.category,
    required this.type,
    this.officialUrl,
    this.logoSourceUrl,
    this.assetPath,
    required this.verificationStatus,
    this.notes,
  });
}

class MemberLogo extends StatelessWidget {
  const MemberLogo({
    super.key,
    required this.member,
    this.maxWidth = 180,
    this.maxHeight = 96,
    this.padding = const EdgeInsets.all(18),
  });

  final MemberLogoAsset member;
  final double maxWidth;
  final double maxHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final hasAsset = member.assetPath != null;
    final showDarkBackground =
        member.assetPath != null &&
        (member.assetPath!.endsWith('.webp') ||
            member.assetPath!.contains('funny-lion'));

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth, minHeight: maxHeight),
      padding: padding,
      decoration: BoxDecoration(
        color: showDarkBackground ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: hasAsset
            ? Image.asset(
                member.assetPath!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _MemberLogoFallback(member: member);
                },
              )
            : _MemberLogoFallback(member: member),
      ),
    );
  }
}

class _MemberLogoFallback extends StatelessWidget {
  const _MemberLogoFallback({required this.member});

  final MemberLogoAsset member;

  @override
  Widget build(BuildContext context) {
    return Text(
      member.officialBrandName ?? member.associationName,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.4,
      ),
    );
  }
}

const memberLogoAssets = [
  MemberLogoAsset(
    associationName: 'A&A Plaza Hotel',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl: 'https://www.facebook.com/aaplazahotel/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Astoria Palawan',
    officialBrandName: 'Astoria Palawan',
    category: 'Hotels & Resorts',
    type: 'Resort / Hotel',
    officialUrl: 'https://astoriapalawan.com/',
    logoSourceUrl:
        'https://astoriapalawan.com/wp-content/uploads/2020/03/logo-APW.png',
    assetPath: 'assets/aatappp/members/hotels_resorts/astoria-palawan.png',
    verificationStatus: 'verified_official_website',
  ),
  MemberLogoAsset(
    associationName: 'Aziza Paradise Hotel',
    officialBrandName: 'Aziza Paradise Hotel',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl: 'https://www.azizaparadisehotel.ph/',
    logoSourceUrl:
        'https://www.azizaparadisehotel.ph/wp-content/uploads/2024/06/logo-aziza-1.jpg',
    assetPath: 'assets/aatappp/members/hotels_resorts/aziza-paradise-hotel.jpg',
    verificationStatus: 'verified_official_website',
    notes:
        'Official site exposed a raster logo file rather than a transparent PNG or SVG.',
  ),
  MemberLogoAsset(
    associationName: 'Best Western Plus The Ivywall Hotel',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl:
        'https://www.bestwestern.com/en_US/book/hotels-in-puerto-princesa/best-western-plus-the-ivywall-hotel-palawan/propertyCode.99104.html',
    verificationStatus: 'needs_manual_review',
    notes:
        'Official Best Western property page was reachable, but the correct property-associated brand asset was not confidently isolated in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Citystate Asturias Hotel',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl: 'https://www.facebook.com/citystateasturias/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Costa Palawan Resort',
    category: 'Hotels & Resorts',
    type: 'Resort',
    officialUrl: 'https://costapalawanresort.com/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Official site did not expose a confidently retrievable logo asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Daluyon Beach and Mountain Resort',
    officialBrandName: 'Daluyon Beach and Mountain Resort',
    category: 'Hotels & Resorts',
    type: 'Beach / Mountain Resort',
    officialUrl: 'https://daluyonbeachandmountainresort.com/',
    logoSourceUrl:
        'https://daluyonbeachandmountainresort.com/wp-content/themes/yootheme/cache/Daluyon-logo-No-BG_19617112058-e1570772333736-e2768099.png',
    assetPath:
        'assets/aatappp/members/hotels_resorts/daluyon-beach-and-mountain-resort.png',
    verificationStatus: 'verified_official_website',
  ),
  MemberLogoAsset(
    associationName: 'Empire Suites Hotel',
    category: 'Hotels & Resorts',
    type: 'Suites Hotel',
    officialUrl: 'https://www.facebook.com/holidaysuitesbusinessdistrict/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Potential branding conflict with Holiday Suites Business District; no safe substitution made.',
  ),
  MemberLogoAsset(
    associationName: 'Fersal Hotel - Puerto Princesa',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl:
        'https://fersalhotel.com/fersal-hotel-puerto-princesa-city-palawan/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Official site was reachable, but a clean direct property logo asset was not confidently isolated in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Four Points by Sheraton Palawan',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl:
        'https://www.marriott.com/en-us/hotels/ppsfp-four-points-palawan-puerto-princesa/overview/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Official Marriott property page was reachable, but the correct Four Points brand asset was not confidently isolated in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Go Hotels Puerto Princesa',
    officialBrandName: 'Go Hotels',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl: 'https://gohotels.ph/branch/puerto-princesa',
    logoSourceUrl:
        'https://gohotels.ph/themes/custom/rhr_gohotels/images/logo/logo-green.png',
    assetPath:
        'assets/aatappp/members/hotels_resorts/go-hotels-puerto-princesa.png',
    verificationStatus: 'verified_official_website',
    notes:
        'Downloaded from the official Go Hotels branch site; chain brand mark rather than a branch-specific lockup.',
  ),
  MemberLogoAsset(
    associationName: 'Holiday Suites Puerto Princesa',
    officialBrandName: 'Holiday Suites',
    category: 'Hotels & Resorts',
    type: 'Suites Hotel',
    officialUrl: 'https://holidaysuites.ph/',
    logoSourceUrl: 'https://holidaysuites.ph/img/hs-logo.png',
    assetPath:
        'assets/aatappp/members/hotels_resorts/holiday-suites-puerto-princesa.png',
    verificationStatus: 'verified_official_website',
  ),
  MemberLogoAsset(
    associationName: 'Microtel by Wyndham',
    officialBrandName: 'Microtel by Wyndham Puerto Princesa',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl: 'https://microtel-palawan.com/',
    logoSourceUrl:
        'https://ireward.superghs.com/resource/microtelpuertoprincesa/logo/logo.png?v1.0004',
    assetPath: 'assets/aatappp/members/hotels_resorts/microtel-by-wyndham.png',
    verificationStatus: 'verified_official_website',
  ),
  MemberLogoAsset(
    associationName: 'Palawan Uno Hotel',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl: 'https://www.facebook.com/palawanunohotel/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Sotogrande Palawan Hotel',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl: 'https://www.facebook.com/officialsotograndepalawan/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Sunlight Guest Hotel Inc.',
    category: 'Hotels & Resorts',
    type: 'Guest Hotel',
    officialUrl:
        'https://www.facebook.com/pages/Sunlight-Guest-Hotel-Puerto-Princesa-Palawan/310557065634916',
    verificationStatus: 'needs_manual_review',
    notes:
        'Property identity needs confirmation specifically for the Puerto Princesa property.',
  ),
  MemberLogoAsset(
    associationName: 'The Dome Palawan',
    category: 'Hotels & Resorts',
    type: 'Hotel / Resort',
    officialUrl: 'https://www.facebook.com/thedomepuertoprincesa/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'The Funny Lion - Puerto Princesa',
    officialBrandName: 'The Funny Lion',
    category: 'Hotels & Resorts',
    type: 'Hotel / Resort',
    officialUrl: 'https://www.thefunnylion.com/',
    logoSourceUrl:
        'https://images.squarespace-cdn.com/content/v1/633baf35752b3571b1938cdf/b2effb2b-37f4-40d5-b572-186a3752eae7/The+Funny+Lion+white.png?format=1500w',
    assetPath:
        'assets/aatappp/members/hotels_resorts/the-funny-lion-puerto-princesa.webp',
    verificationStatus: 'verified_official_website',
    notes:
        'Downloaded from the official site header logo URL. Returned as WebP.',
  ),
  MemberLogoAsset(
    associationName: 'Princesa Garden Island Resort',
    officialBrandName: 'Princesa Garden Island Resort',
    category: 'Hotels & Resorts',
    type: 'Resort',
    officialUrl: 'https://www.princesagardenisland.com/',
    logoSourceUrl:
        'https://www.princesagardenisland.com/wp-content/uploads/2024/06/main-logo-1.png',
    assetPath:
        'assets/aatappp/members/hotels_resorts/princesa-garden-island-resort.png',
    verificationStatus: 'verified_official_website',
  ),
  MemberLogoAsset(
    associationName: 'Crown Hotel Palawan at Harbour Springs',
    officialBrandName: 'Crown Hotel Palawan',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl: 'https://crownhotelpalawan.com/',
    logoSourceUrl:
        'https://crownhotelpalawan.com/wp-content/uploads/2023/07/cropped-Crown-Hotel-Logo-e1690342986758.png',
    assetPath:
        'assets/aatappp/members/hotels_resorts/crown-hotel-palawan-at-harbour-springs.png',
    verificationStatus: 'verified_official_website',
    notes:
        'Official site exposed a cropped logo image; retained as downloaded because it is property-controlled.',
  ),
  MemberLogoAsset(
    associationName: 'Hotel Centro',
    category: 'Hotels & Resorts',
    type: 'Hotel',
    officialUrl: 'https://www.facebook.com/HotelCentro/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Ala Amid Bed & Breakfast',
    category: 'Mabuhay Accommodations',
    type: 'Bed & Breakfast',
    officialUrl: 'https://www.facebook.com/alaamidbedandbreakfast/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Alvea Hotel - Puerto Princesa',
    officialBrandName: 'Alvea Hotel',
    category: 'Mabuhay Accommodations',
    type: 'Hotel',
    officialUrl: 'https://www.alvea.com.ph/',
    logoSourceUrl:
        'https://www.alvea.com.ph/wp-content/uploads/2022/05/logo.png',
    assetPath: 'assets/aatappp/members/mabuhay/alvea-hotel-puerto-princesa.png',
    verificationStatus: 'verified_official_website',
  ),
  MemberLogoAsset(
    associationName: 'Angelic Mansion',
    officialBrandName: 'Angelic Mansion',
    category: 'Mabuhay Accommodations',
    type: 'Mansion / Accommodation',
    officialUrl: 'https://www.angelicmansion.com/',
    logoSourceUrl:
        'https://s3-cdn.hotellinksolutions.com/hls/data/1033/website/general/lg/normal_angelic-mansion-logo.png',
    assetPath: 'assets/aatappp/members/mabuhay/angelic-mansion.png',
    verificationStatus: 'verified_official_website',
  ),
  MemberLogoAsset(
    associationName: 'Bambu Suites',
    category: 'Mabuhay Accommodations',
    type: 'Suites',
    officialUrl: 'https://www.facebook.com/bambusuitespalawan/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Blue Lagoon Inn & Suites',
    category: 'Mabuhay Accommodations',
    type: 'Inn / Suites',
    officialUrl:
        'https://www.facebook.com/p/Blue-Lagoon-Inn-Suites-100064013111248/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Cafemoto Lifestyle',
    category: 'Mabuhay Accommodations',
    type: 'Lifestyle Accommodation',
    officialUrl: 'https://www.facebook.com/onehundredpercentcafemoto/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Property-controlled source appears to use 100% Cafe Moto branding; discrepancy recorded, no logo downloaded.',
  ),
  MemberLogoAsset(
    associationName: 'Canvass Boutique Hotel',
    officialBrandName: 'Canvas Boutique Hotel',
    category: 'Mabuhay Accommodations',
    type: 'Boutique Hotel',
    officialUrl: 'https://canvasboutiquehotel.com/',
    logoSourceUrl:
        'https://canvasboutiquehotel.com/wp-content/uploads/2022/08/CANVAS-transparent-png-scaled.png',
    assetPath: 'assets/aatappp/members/mabuhay/canvas-boutique-hotel.png',
    verificationStatus: 'verified_official_website',
    notes:
        'Association listing spells the property as Canvass Boutique Hotel; official branding uses Canvas Boutique Hotel.',
  ),
  MemberLogoAsset(
    associationName: 'Casa Belina Tourist Inn',
    category: 'Mabuhay Accommodations',
    type: 'Tourist Inn',
    officialUrl: 'https://www.facebook.com/casabelinatouristinn/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Casa De Praxides Tourist Inn',
    category: 'Mabuhay Accommodations',
    type: 'Tourist Inn',
    officialUrl:
        'https://www.facebook.com/p/Casa-de-Praxides-Tourist-Inn-61551913493742/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Casana Suites',
    category: 'Mabuhay Accommodations',
    type: 'Suites',
    officialUrl: 'https://www.facebook.com/casanassuitepalawan/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Possible current spelling Casañas Suites; discrepancy recorded, no confidently extracted asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: "D' Beach Resort",
    category: 'Mabuhay Accommodations',
    type: 'Beach Resort',
    officialUrl: 'https://www.facebook.com/DBeachResortPuertoPrincesa/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Diakopes Inn',
    category: 'Mabuhay Accommodations',
    type: 'Inn',
    officialUrl: 'https://www.facebook.com/diakopesinn/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Dinah’s Tourist Inn',
    category: 'Mabuhay Accommodations',
    type: 'Tourist Inn',
    officialUrl: 'https://dinahspensionhouse.zoombookdirect.com/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Property-controlled source suggests Dinah’s Pension House branding; discrepancy recorded, no safe logo download in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Dolce Vita Hotel & Restaurant',
    category: 'Mabuhay Accommodations',
    type: 'Hotel',
    officialUrl:
        'https://www.facebook.com/p/Dolce-Vita-Hotel-Restaurant-100064061413758/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Elleis Place',
    category: 'Mabuhay Accommodations',
    type: 'Accommodation',
    officialUrl: 'https://www.facebook.com/elleisplace/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Escape Boutique Hotel',
    category: 'Mabuhay Accommodations',
    type: 'Boutique Hotel',
    officialUrl:
        'https://www.facebook.com/p/Escape-Boutique-Hotel-by-FarmBihira-Farm-61553132618395/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Current official page includes additional by FarmBihira Farm wording; no confidently extracted asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Grande Vista Hotel',
    category: 'Mabuhay Accommodations',
    type: 'Hotel',
    officialUrl: 'https://www.facebook.com/Gvh12/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Hotel Palacio',
    category: 'Mabuhay Accommodations',
    type: 'Hotel',
    officialUrl: 'https://www.hotelpalaciopalawan.com/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Official site was reachable, but a clean direct logo asset was not confidently isolated in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'KSK Serenity Resort',
    category: 'Mabuhay Accommodations',
    type: 'Resort',
    officialUrl:
        'https://www.facebook.com/p/KSK-Serenity-Resort-61557125019785/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Lokal Hut Bed and Breakfast',
    category: 'Mabuhay Accommodations',
    type: 'Bed & Breakfast',
    officialUrl: 'https://www.facebook.com/p/The-Lokal-Hut-61556669164959/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Official branding may use The Lokal Hut; discrepancy recorded, no confidently extracted asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Lola Itangs Pension House',
    category: 'Mabuhay Accommodations',
    type: 'Pension House',
    officialUrl: 'https://www.facebook.com/lolaitangpalawan/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Orange Mangrove Pension House',
    category: 'Mabuhay Accommodations',
    type: 'Pension House',
    officialUrl: 'https://www.orangemangrovehotel.com/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Official source suggests Orange Mangrove Hotel branding, but direct logo retrieval was not confidently completed in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'One Eight Residences Inn',
    officialBrandName: 'One Eight Residence Inn',
    category: 'Mabuhay Accommodations',
    type: 'Residences / Inn',
    officialUrl: 'https://oneeightresidenceinn.com/',
    logoSourceUrl:
        'https://oneeightresidenceinn.com/wp-content/uploads/2021/05/18-logo-flat.png',
    assetPath: 'assets/aatappp/members/mabuhay/one-eight-residence-inn.png',
    verificationStatus: 'verified_official_website',
    notes:
        'Association listing uses One Eight Residences Inn; official site uses One Eight Residence Inn.',
  ),
  MemberLogoAsset(
    associationName: 'Puerto Pension Inn',
    category: 'Mabuhay Accommodations',
    type: 'Pension House / Inn',
    officialUrl: 'https://www.facebook.com/puertopensioninn/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Rodolfo Royale Hotel',
    category: 'Mabuhay Accommodations',
    type: 'Hotel',
    officialUrl:
        'https://www.facebook.com/p/Rodolfo-Royale-HOTEL-61571256355874/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Sandy Beach Hotel and Resort',
    category: 'Mabuhay Accommodations',
    type: 'Hotel / Resort',
    verificationStatus: 'missing',
    notes:
        'No sufficiently verified official source was available in the supplied manifest; intentionally left without a downloaded logo.',
  ),
  MemberLogoAsset(
    associationName: 'Sheridan Boutique Hotel',
    category: 'Mabuhay Accommodations',
    type: 'Boutique Hotel',
    officialUrl: 'https://sheridanboutiquehotel.com/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Official site was listed, but a clean direct logo asset was not confidently isolated in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Southwind Palawan',
    category: 'Mabuhay Accommodations',
    type: 'Accommodation',
    officialUrl: 'https://www.facebook.com/southwindpalawan/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Upgrace Inn',
    category: 'Mabuhay Accommodations',
    type: 'Inn',
    officialUrl: 'https://www.facebook.com/UpgraceInn/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Facebook-only source; no confidently extracted official brand asset in this pass.',
  ),
  MemberLogoAsset(
    associationName: 'Wanderlust Bed & Breakfast',
    officialBrandName: 'Wanderlust',
    category: 'Mabuhay Accommodations',
    type: 'Bed & Breakfast',
    officialUrl: 'https://wanderlustpalawan.com/',
    logoSourceUrl:
        'https://wanderlustpalawan.com/wp-content/uploads/2026/07/Logo-Font-e1677468406890.png',
    assetPath:
        'assets/aatappp/members/mabuhay/wanderlust-bed-and-breakfast.png',
    verificationStatus: 'verified_official_website',
  ),
  MemberLogoAsset(
    associationName: 'Whitebreeze Palawan Hotel',
    category: 'Mabuhay Accommodations',
    type: 'Hotel',
    officialUrl: 'https://www.facebook.com/whitebreezepalawan/',
    verificationStatus: 'needs_manual_review',
    notes:
        'Association listing may differ from White Breeze Palawan branding; no confidently extracted official asset in this pass.',
  ),
];
