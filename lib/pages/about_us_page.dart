import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final List<Map<String, String>> items = [
    {
      'title': 'Our Vision',
      'description': 'To bridge the gap between the youth and meaningful charitable activities. We make service fun and rewarding!',
    },
    {
      'title': 'Our Story',
      'description': 'Born from the idea of simplifying community service. We provide a platform to discover, connect, and give back.',
    },
    {
      'title': 'Opportunities at Your Fingertips',
      'description': 'Easily explore projects that matter to you.',
    },
    {
      'title': 'User-Friendly Experience',
      'description': 'Simple and impactful for students, volunteers, and NGOs.',
    },
    {
      'title': 'Meaningful Engagement',
      'description': 'Track progress, earn recognition, and make a difference.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'About Us'.tr(),
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.description,
                style: TextStyle(
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
