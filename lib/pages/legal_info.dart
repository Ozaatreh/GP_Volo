import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class LegalInfoPage extends StatefulWidget {
  const LegalInfoPage({Key? key}) : super(key: key);

  @override
  State<LegalInfoPage> createState() => _LegalInfoPageState();
}

class _LegalInfoPageState extends State<LegalInfoPage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> items = [
    {
      'title': 'Terms of Service',
      'description':
          'By using our platform, you agree to abide by our rules and regulations. Ensure you provide accurate information and avoid prohibited activities.'.tr(),
    },
    {
      'title': 'Privacy Policy',
      'description':
          'We value your privacy. Your data is used to enhance your experience. You can request to access or delete your data anytime.'.tr(),
    },
    {
      'title': 'Disclaimer',
      'description':
          'Our app acts as an intermediary. We are not liable for actions or interactions between users or third parties.',
    },
    {
      'title': 'Community Guidelines',
      'description':
          'Respect, inclusivity, and cooperation are key to our community. Violating these guidelines may lead to account suspension.',
    },
    {
      'title': 'Contact Us',
      'description':
          'For legal or compliance concerns, feel free to reach out via our support email.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title:  Text('Legal Information'.tr(), style: TextStyle(color:Theme.of(context).colorScheme.inversePrimary,)),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return FadeInCard(
            title: items[index]['title']!.tr(),
            description: items[index]['description']!.tr(),
            delay: index * 300,
          );
        },
      ),
    );
  }
}

class FadeInCard extends StatefulWidget {
  final String title;
  final String description;
  final int delay;

  const FadeInCard({
    Key? key,
    required this.title,
    required this.description,
    required this.delay,
  }) : super(key: key);

  @override
  State<FadeInCard> createState() => _FadeInCardState();
}

class _FadeInCardState extends State<FadeInCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
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
      opacity: _fadeAnimation,
      child: Card(
        color: Theme.of(context).colorScheme.primary,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style:   TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.description,
                style:   TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}