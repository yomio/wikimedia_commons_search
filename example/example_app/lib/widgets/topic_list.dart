import 'package:flutter/material.dart';
import 'topic_list_item.dart';

class TopicList extends StatelessWidget {
  final List<Map<String, dynamic>> topics;
  final Function(Map<String, dynamic>) onTopicSelected;

  const TopicList({
    super.key,
    required this.topics,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final topic = topics[index];
        return TopicListItem(
          topic: topic,
          onTap: () => onTopicSelected(topic),
        );
      },
    );
  }
}
