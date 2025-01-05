import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'What is this app about?',
      'answer': 'This app is designed to simplify community service and charity work for youth by connecting volunteers, NGOs, universities, and leaders. It offers a platform where users can manage profiles, explore opportunities, and collaborate efficiently.',
    },
    {
      'question': 'Who can use this app?',
      'answer': 'The app is tailored for:\n- Volunteers: Individuals looking to participate in events or causes.\n- NGO Representatives: Organizations hosting events or initiatives.\n- University Representatives: Institutions offering community service opportunities for students.\n- Leaders: Volunteers with additional privileges to manage events or teams.',
    },
    {
      'question': 'Is the app free to use?',
      'answer': 'Yes, the app is completely free to download and use for all user types.',
    },
    {
      'question': 'How do I create an account?',
      'answer': 'You can create an account by signing up with your email or Google account. During registration, you\'ll also select your user type (Volunteer, NPO, University, or Leader).',
    },
    {
      'question': 'Can I change my user type after registration?',
      'answer': 'Currently, user types are fixed upon registration. For assistance, contact support.',
    },
    {
      'question': 'What do I do if I forget my password?',
      'answer': 'Use the Forgot Password option on the login page to reset your password via email.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'FAQ',
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        
        padding: const EdgeInsets.all(16.0),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return FadeInFAQCard(
            question: faqs[index]['question']!.tr(),
            answer: faqs[index]['answer']!.tr(),
            delay: index * 300,
          );
        },
      ),
    );
  }
}

class FadeInFAQCard extends StatefulWidget {
  final String question;
  final String answer;
  final int delay;

  const FadeInFAQCard({
    Key? key,
    required this.question,
    required this.answer,
    required this.delay,
  }) : super(key: key);

  @override
  State<FadeInFAQCard> createState() => _FadeInFAQCardState();
}

class _FadeInFAQCardState extends State<FadeInFAQCard>
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
        child: ExpansionTile(
          title: Text(
            widget.question,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.answer,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
