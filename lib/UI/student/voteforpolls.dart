import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class votepollpage extends StatefulWidget {
  const votepollpage({Key? key}) : super(key: key);

  @override
  State<votepollpage> createState() => _VotePollPageState();
}

class _VotePollPageState extends State<votepollpage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vote on Polls"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('polls')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No polls available."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot pollDocument = snapshot.data!.docs[index];
              Map<String, dynamic> pollData =
                  pollDocument.data() as Map<String, dynamic>;

              return PollCard(pollData: pollData, pollId: pollDocument.id);
            },
          );
        },
      ),
    );
  }
}

class PollCard extends StatefulWidget {
  final Map<String, dynamic> pollData;
  final String pollId;

  const PollCard({Key? key, required this.pollData, required this.pollId})
      : super(key: key);

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  String? _selectedOption;
  bool _hasVoted = false; // Track if the user has voted

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.pollData['question'],
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            // Options
            ..._buildOptions(),
            const SizedBox(height: 10.0),

            // Vote Button (conditionally displayed)
            if (!_hasVoted)
              ElevatedButton(
                onPressed: _selectedOption != null ? () => _handleVote() : null,
                child: const Text("Vote"),
              ),

            // Vote Counts
            ..._buildVoteCounts(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions() {
    List<Widget> options = [];
    // Assuming you have option names as keys in the 'votes' map
    // You might need to adjust this based on how your options are stored
    if (widget.pollData.containsKey('option1')) {
      options.add(
        ListTile(
          title: Text(widget.pollData['option1']),
          leading: Radio<String>(
            value: widget.pollData['option1'],
            groupValue: _selectedOption,
            onChanged: _hasVoted
                ? null
                : (String? value) {
                    // Disable if already voted
                    setState(() {
                      _selectedOption = value;
                    });
                  },
          ),
        ),
      );
    }
    if (widget.pollData.containsKey('option2')) {
      options.add(
        ListTile(
          title: Text(widget.pollData['option2']),
          leading: Radio<String>(
            value: widget.pollData['option2'],
            groupValue: _selectedOption,
            onChanged: _hasVoted
                ? null
                : (String? value) {
                    setState(() {
                      _selectedOption = value;
                    });
                  },
          ),
        ),
      );
    }
    // Add more options as needed
    return options;
  }

  List<Widget> _buildVoteCounts() {
    List<Widget> voteCounts = [];
    Map<String, dynamic> votes = widget.pollData['votes'];

    votes.forEach((option, count) {
      voteCounts.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text("$option: $count votes"),
        ),
      );
    });

    return voteCounts;
  }

  void _handleVote() {
    if (_selectedOption != null) {
      FirebaseFirestore.instance.collection('polls').doc(widget.pollId).update({
        "votes.$_selectedOption": FieldValue.increment(1),
      }).then((_) {
        setState(() {
          _hasVoted = true; // User has now voted
          // Update vote counts in pollData (to avoid another fetch)
          widget.pollData['votes'][_selectedOption]++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vote submitted!")),
        );
      }).catchError((error) {
        print("Error updating vote: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting vote: $error")),
        );
      });
    }
  }
}
