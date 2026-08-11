import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/community_theme_entity.dart';
import 'hex_color.dart';

class AssociateInfoSheet extends StatelessWidget {
  final String type;
  final CommunityThemeEntity theme;

  const AssociateInfoSheet({
    super.key,
    required this.type,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'About Us':
        return _AboutUsSheet(theme: theme);
      case 'By Laws':
        return _ByLawsSheet(theme: theme);
      case 'Founders':
        return _FoundersSheet(theme: theme);
      case 'Donations':
        return _DonationsSheet(theme: theme);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _BaseSheet extends StatelessWidget {
  final String title;
  final CommunityThemeEntity theme;
  final List<Widget> children;

  const _BaseSheet({
    required this.title,
    required this.theme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      constraints: BoxConstraints(maxHeight: 0.9.sh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
            child: Row(
              children: [
                Icon(Icons.home_outlined, color: accent, size: 28.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 20.sp, color: primary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Flexible(
            child: ListView(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 32.h),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutUsSheet extends StatelessWidget {
  final CommunityThemeEntity theme;
  const _AboutUsSheet({required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();
    final textSecondary = theme.textSecondary.toColor();

    return _BaseSheet(
      title: 'About Us',
      theme: theme,
      children: [
        Text(
          'The Tamil Nadu IT Hostels & PG Owners Welfare Association brings together owners of working-professional hostels and paying-guest accommodations across the state, so that a single, organised voice speaks for the trade.',
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            color: Colors.black87,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 24.h),
        _buildHeading('What we do', primary),
        SizedBox(height: 12.h),
        ...[
          'Represent owners before civic bodies, licensing authorities and the police on registration, safety and taxation matters.',
          'Circulate rule changes, inspection notices and compliance deadlines to every zone.',
          'Run legal and documentation help desks for members facing disputes or notices.',
          'Set shared standards for tenant safety, hygiene and fair rental practice.',
          'Hold zonal meets so owners can raise local issues with the state committee.',
        ].map((item) => _buildBulletItem(item, accent)),
        SizedBox(height: 24.h),
        _buildHeading('How we are organised', primary),
        SizedBox(height: 12.h),
        Text(
          'A state executive committee leads the association. Ten zones cover Tamil Nadu, each headed by executive members who work with their own core member teams on the ground. An IT wing maintains the member directory, ID cards and digital records.',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24.h),
        _buildHeading('Contact us before you join', primary),
        SizedBox(height: 12.h),
        Text(
          'Not sure whether your facility qualifies, or what the fee and documents are? Call the membership desk — you do not need to be a member to ask.',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: textSecondary,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Membership enquiries',
              style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
            ),
            Text(
              '+91 98400 12345',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        const Divider(color: Color(0xFFE2E8F0)),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Desk hours',
              style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
            ),
            Text(
              'Monday to Saturday, 10am to 6pm',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 32.h),
        _buildInfoBox(
          'Membership is open to any registered hostel or PG owner in Tamil Nadu. Use Join now on the home screen to register and receive your membership ID.',
          theme,
        ),
      ],
    );
  }
}

class _ByLawsSheet extends StatelessWidget {
  final CommunityThemeEntity theme;
  const _ByLawsSheet({required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();

    final clauses = [
      {'title': 'Name and area', 'content': 'The association is called the Tamil Nadu IT Hostels & PG Owners Welfare Association and operates throughout Tamil Nadu.'},
      {'title': 'Objects', 'content': 'To protect the lawful interests of hostel and PG owners, to promote safe and fair accommodation, and to act as the trade\'s representative before authorities.'},
      {'title': 'Eligibility', 'content': 'Any person or firm running a registered hostel or PG facility in Tamil Nadu may apply for membership.'},
      {'title': 'Subscription', 'content': 'The annual membership fee is payable at the time of joining and every year thereafter. Membership lapses if the fee is not renewed.'},
      {'title': 'Membership ID', 'content': 'Each member is issued a unique ID card. It is not transferable and must be surrendered when membership ends.'},
      {'title': 'Zones', 'content': 'The state is divided into zones. Every member belongs to the zone in which the facility is located.'},
      {'title': 'Executive committee', 'content': 'Office bearers are elected by the general body for a term of two years and may be re-elected once.'},
      {'title': 'Meetings', 'content': 'The general body meets once a year. The executive committee meets at least once a quarter, and zonal meets are held as required.'},
      {'title': 'Accounts', 'content': 'All receipts and payments are recorded and audited annually, and the audited statement is placed before the general body.'},
      {'title': 'Conduct', 'content': 'Members must follow the law on registration, safety, sanitation and tenant records, and must not misuse the association\'s name.'},
      {'title': 'Discipline', 'content': 'Membership may be suspended or cancelled for conduct that harms the association or its members, after the member has been given a hearing.'},
      {'title': 'Amendment', 'content': 'These by laws may be amended by a two-thirds majority of members present at a general body meeting.'},
    ];

    return _BaseSheet(
      title: 'By Laws',
      theme: theme,
      children: [
        Text(
          'These clauses govern membership, conduct and administration. They were adopted by the general body and may be amended only at a general body meeting.',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        SizedBox(height: 24.h),
        _buildHeading('Clauses', primary),
        SizedBox(height: 16.h),
        ...List.generate(clauses.length, (index) {
          final clause = clauses[index];
          final num = (index + 1).toString().padLeft(2, '0');
          return Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.badgeBackground.toColor(),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    num,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.badgeText.toColor(),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black87, height: 1.4),
                      children: [
                        TextSpan(
                          text: '${clause['title']}. ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: clause['content']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 12.h),
        _buildInfoBox(
          'This is a summary for members. The full registered by laws are available from the state secretary on request.',
          theme,
        ),
      ],
    );
  }
}

class _FoundersSheet extends StatelessWidget {
  final CommunityThemeEntity theme;
  const _FoundersSheet({required this.theme});

  @override
  Widget build(BuildContext context) {
    final primary = theme.primaryColor.toColor();
    final accent = theme.accentColor.toColor();
    final badgeBg = theme.badgeBackground.toColor();
    final badgeText = theme.badgeText.toColor();

    final founders = [
      {'id': 'TNIT-FDR-01', 'name': 'Founder Name', 'role': 'FOUNDER', 'photoUrl': ''},
      {'id': 'TNIT-FDR-02', 'name': 'Founder Name', 'role': 'CO-FOUNDER', 'photoUrl': ''},
    ];

    return _BaseSheet(
      title: 'Founders',
      theme: theme,
      children: [
        Text(
          'The association was formed by owners who wanted the trade to be heard as one voice. Its founders continue to guide the state committee.',
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        SizedBox(height: 32.h),
        Row(
          children: founders.map((f) => Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 36.r,
                      backgroundColor: accent.withValues(alpha: 0.1),
                      child: Icon(Icons.person, color: accent, size: 36.sp),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    f['name']!,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    f['role']!,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: accent,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'ID ${f['id']}',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: badgeText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _DonationsSheet extends StatefulWidget {
  final CommunityThemeEntity theme;
  const _DonationsSheet({required this.theme});

  @override
  State<_DonationsSheet> createState() => _DonationsSheetState();
}

class _DonationsSheetState extends State<_DonationsSheet> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final primary = widget.theme.primaryColor.toColor();
    final accent = widget.theme.accentColor.toColor();
    final badgeBg = widget.theme.badgeBackground.toColor();
    final badgeText = widget.theme.badgeText.toColor();

    final records = [
      {'donor': 'G. Naveen', 'category': 'Meals', 'desc': 'Lunch for 180 - State general body meet', 'zone': 'Chennai Zone', 'date': '12 Jul 2026', 'isKind': true},
      {'donor': 'M. Elango', 'category': 'Money', 'desc': 'Legal aid fund', 'zone': 'Madurai Zone', 'date': '03 Jul 2026', 'amount': '₹25,000'},
      {'donor': 'N. Pandian', 'category': 'Water', 'desc': '40 water cans - Zonal meet, Coimbatore', 'zone': 'Coimbatore Zone', 'date': '05 Jul 2026', 'isKind': true},
      {'donor': 'N. Suresh', 'category': 'Stationery', 'desc': '250 notebooks, 20 registers - Zonal office records', 'zone': 'Trichy Zone', 'date': '28 Jun 2026', 'isKind': true},
      {'donor': 'N. Sundar', 'category': 'Meals', 'desc': 'Dinner for 90 - Executive committee meeting', 'zone': 'Chennai Zone', 'date': '18 Jun 2026', 'isKind': true},
      {'donor': 'N. Sundar', 'category': 'Other', 'desc': '2 fire extinguishers, 5 first-aid kits - Safety training camp', 'zone': 'Tiruppur Zone', 'date': '11 Jun 2026', 'isKind': true},
      {'donor': 'E. Thiru', 'category': 'Money', 'desc': 'Annual meet expenses', 'zone': 'Erode Zone', 'date': '03 Jun 2026', 'amount': '₹5,000'},
      {'donor': 'T. Raghu', 'category': 'Water', 'desc': '25 water cans - Awareness camp', 'zone': 'Tirunelveli Zone', 'date': '27 May 2026', 'isKind': true},
      {'donor': 'C. Senthilkumar', 'category': 'Stationery', 'desc': '500 printed compliance guides - Distributed to all zones', 'zone': 'Vellore Zone', 'date': '21 May 2026', 'isKind': true},
    ];

    final filteredRecords = _activeFilter == 'All' 
        ? records 
        : records.where((r) => r['category'] == _activeFilter).toList();

    return _BaseSheet(
      title: 'Donations',
      theme: widget.theme,
      children: [
        Text(
          'Donations recorded by the state treasurer. Members contribute money as well as meals, stationery, drinking water and equipment for meets and camps.',
          style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black87, height: 1.4),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            _buildStatCard('MONEY RECEIVED', '₹1,05,000', primary),
            SizedBox(width: 12.w),
            _buildStatCard('IN-KIND GIFTS', '9', primary),
          ],
        ),
        SizedBox(height: 20.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['All', 'Money', 'Stationery', 'Meals', 'Water', 'Other'].map((f) => 
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: FilterChip(
                  label: Text(f),
                  selected: _activeFilter == f,
                  onSelected: (val) => setState(() => _activeFilter = f),
                  selectedColor: primary,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: _activeFilter == f ? Colors.white : Colors.grey.shade600,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  side: BorderSide(color: _activeFilter == f ? primary : Colors.grey.shade200),
                  showCheckmark: false,
                ),
              )
            ).toList(),
          ),
        ),
        SizedBox(height: 16.h),
        ...filteredRecords.map((r) => _buildDonationCard(r, primary, accent, badgeBg, badgeText)),
        SizedBox(height: 24.h),
        _buildInfoBox(
          'To donate, tell your zone executive member what you would like to give. Money donations can be sent by UPI to tnithostels@upi — send the transaction reference to the state treasurer for your receipt.',
          widget.theme,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color primary) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5),
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w800, color: primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> r, Color primary, Color accent, Color badgeBg, Color badgeText) {
    IconData icon;
    switch (r['category']) {
      case 'Meals': icon = Icons.restaurant_outlined; break;
      case 'Water': icon = Icons.water_drop_outlined; break;
      case 'Stationery': icon = Icons.description_outlined; break;
      case 'Money': icon = Icons.currency_rupee_outlined; break;
      default: icon = Icons.redeem_outlined;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: primary, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          r['donor'],
                          style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                        ),
                        if (r['isKind'] == true)
                          Text(
                            'IN KIND',
                            style: GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
                          )
                        else
                          Text(
                            r['amount'],
                            style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w800, color: accent),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      r['desc'],
                      style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey.shade600, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              SizedBox(width: 44.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  r['category'].toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 9.sp, fontWeight: FontWeight.w800, color: badgeText),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${r['zone']}  •  ${r['date']}',
                style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable components
Widget _buildHeading(String title, Color color) {
  return Text(
    title,
    style: GoogleFonts.inter(
      fontSize: 17.sp,
      fontWeight: FontWeight.w700,
      color: color,
    ),
  );
}

Widget _buildBulletItem(String text, Color accent) {
  return Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.black87, height: 1.4),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoBox(String text, CommunityThemeEntity theme) {
  return Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF7EE),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: const Color(0xFFD5EBD2)),
    ),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        color: const Color(0xFF3E7A34),
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
    ),
  );
}
