import 'package:flutter/material.dart';

void main() => runApp(const OctansApp());

class OctansApp extends StatelessWidget {
  const OctansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Octans Insurance — Life Quest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B3D91)),
        useMaterial3: true,
      ),
      home: const EmailGateScreen(),
    );
  }
}

class EmailGateScreen extends StatefulWidget {
  const EmailGateScreen({super.key});
  @override
  State<EmailGateScreen> createState() => _EmailGateScreenState();
}

class _EmailGateScreenState extends State<EmailGateScreen> {
  final TextEditingController _email = TextEditingController();
  bool agreed = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Image.asset('assets/images/logo.png', height: 120, fit: BoxFit.contain),
              const SizedBox(height: 12),
              const Text('Octans Life Quest', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Learn the basics of life insurance the fun way.', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email to start',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(value: agreed, onChanged: (v){ setState(()=>agreed=v??false); }),
                  const Expanded(child: Text('I agree to be contacted by Octans Insurance about helpful resources.')),
                ],
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () {
                  if ((_formKey.currentState?.validate() ?? false) && agreed) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LevelSelectScreen(email: _email.text)));
                  }
                },
                child: const Text('Start'),
              ),
              const Spacer(),
              const Text('© Octans Insurance', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelSelectScreen extends StatefulWidget {
  final String email;
  const LevelSelectScreen({super.key, required this.email});
  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final Map<String, bool> badges = {
    'Term Life': false,
    'Whole Life': false,
    'IUL': false,
    'Juvenile': false,
    'Accidental': false,
  };

  void _openLevel(String name) async {
    final score = await Navigator.push<int>(context, MaterialPageRoute(builder: (_) => QuizScreen(title: name, questions: questionBank[name] ?? [])));
    if (score != null) {
      setState(() { badges[name] = true; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Completed $name with score $score')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Level')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: badges.keys.map((k) {
            final earned = badges[k] ?? false;
            return Card(
              child: ListTile(
                title: Text(k),
                subtitle: Text(earned ? 'Badge earned 🏅' : 'Not completed'),
                trailing: const Icon(Icons.play_arrow),
                onTap: () => _openLevel(k),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  const QuizScreen({super.key, required this.title, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int idx = 0;
  int score = 0;
  bool locked = false;

  void answer(int i) {
    if (locked) return;
    setState(()=>locked=true);
    final q = widget.questions[idx];
    final bool correct = i == q.correctIndex;
    if (correct) score += 10;
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(correct ? 'Correct 🎉' : 'Nice try'),
      content: Text(q.explainer),
      actions: [
        TextButton(onPressed: () {
          Navigator.pop(c);
          setState((){
            locked=false;
            if (idx < widget.questions.length-1) idx++;
            else Navigator.pop<int>(context, score);
          });
        }, child: const Text('Continue'))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[idx];
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (idx+1)/widget.questions.length),
            const SizedBox(height: 12),
            Text('Question ${idx+1}/${widget.questions.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(q.prompt, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            ...List.generate(q.choices.length, (i) => Card(
              child: ListTile(
                title: Text(q.choices[i]),
                onTap: () => answer(i),
              ),
            )),
            const Spacer(),
            Text('Score: $score'),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String prompt;
  final List<String> choices;
  final int correctIndex;
  final String explainer;
  Question({required this.prompt, required this.choices, required this.correctIndex, required this.explainer});
}

final Map<String, List<Question>> questionBank = {
  'Term Life': [
    Question(
      prompt: 'Term life is best described as:',
      choices: ['Lifetime coverage with cash value', 'Affordable coverage for a set period', 'Investment account only', 'A rider on homeowners insurance'],
      correctIndex: 1,
      explainer: 'Term life provides coverage for a specific term (e.g., 20 years) and is generally the most affordable.',
    ),
    Question(
      prompt: 'What happens when a term policy ends?',
      choices: ['It continues forever', 'It expires or can be renewed (usually at higher cost)', 'It automatically converts to whole life at same premium', 'It becomes an annuity'],
      correctIndex: 1,
      explainer: 'At the end of the term, you may let it expire or renew/convert depending on the policy terms.',
    ),
  ],
  'Whole Life': [
    Question(
      prompt: 'Whole life policies typically include:',
      choices: ['Cash value accumulation', 'No death benefit', 'Variable market returns with no guarantees', 'Coverage that ends after 10 years'],
      correctIndex: 0,
      explainer: 'Whole life offers lifetime coverage and guaranteed cash value growth with level premiums.',
    ),
    Question(
      prompt: 'A common reason to choose Whole Life is:',
      choices: ['Short-term debt coverage only', 'Lifetime coverage with forced savings', 'To avoid all premiums', 'To cover auto accidents only'],
      correctIndex: 1,
      explainer: 'Whole Life provides permanent protection and builds cash value you can borrow against.',
    ),
  ],
  'IUL': [
    Question(
      prompt: 'IUL stands for:',
      choices: ['Indexed Universal Life', 'Individual Utility Loan', 'Investment Unit Life', 'Indexed Unit Liability'],
      correctIndex: 0,
      explainer: 'IUL = Indexed Universal Life — growth tied to an index with caps/floors; principal is protected from market loss (per policy terms).',
    ),
    Question(
      prompt: 'In IUL, cash value growth is typically:',
      choices: ['Directly invested in the stock market', 'Tied to an index with participation rates/caps', 'Guaranteed at 10% annually', 'Only from dividends'],
      correctIndex: 1,
      explainer: 'IUL links interest to an index using caps/floors and participation rates; it is not direct market investment.',
    ),
  ],
  'Juvenile': [
    Question(
      prompt: 'A benefit of juvenile policies is:',
      choices: ['Locks in insurability early', 'Only covers parents', 'No death benefit', 'Guaranteed negative cash value'],
      correctIndex: 0,
      explainer: 'Buying early can lock in insurability and long-term cash value potential.',
    ),
    Question(
      prompt: 'Juvenile policies are owned by:',
      choices: ['Always the child', 'A parent/guardian initially', 'The state', 'A bank'],
      correctIndex: 1,
      explainer: 'A parent/guardian typically owns the policy until ownership is transferred later.',
    ),
  ],
  'Accidental': [
    Question(
      prompt: 'Accidental death benefit pays:',
      choices: ['For any cause of death', 'Only for covered accidents', 'Only for illness', 'Only after age 70'],
      correctIndex: 1,
      explainer: 'AD&D pays if death (or certain losses) result from a covered accident, per policy definitions.',
    ),
    Question(
      prompt: 'AD&D is commonly added as:',
      choices: ['A rider to a life policy', 'A homeowners endorsement', 'A car warranty', 'A mortgage clause'],
      correctIndex: 0,
      explainer: 'Accidental death is often offered as a rider to term or permanent life policies.',
    ),
  ],
};
