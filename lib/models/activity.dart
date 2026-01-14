import 'package:hive/hive.dart';

part 'activity.g.dart';

@HiveType(typeId: 6)
enum ActivityType {
  @HiveField(0)
  envelopeAdded,
  
  @HiveField(1)
  envelopeEdited,
  
  @HiveField(2)
  envelopeDeleted,
}

@HiveType(typeId: 7)
class Activity {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final ActivityType type;
  
  @HiveField(2)
  final List<String> envelopeNames;
  
  @HiveField(3)
  final List<String> envelopeIcons;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final String? envelopeId; // For single envelope actions

  Activity({
    String? id,
    required this.type,
    required this.envelopeNames,
    required this.envelopeIcons,
    required this.timestamp,
    this.envelopeId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Factory for single envelope
  factory Activity.singleEnvelope({
    required ActivityType type,
    required String envelopeName,
    required String envelopeIcon,
    required DateTime timestamp,
    String? envelopeId,
  }) {
    return Activity(
      type: type,
      envelopeNames: [envelopeName],
      envelopeIcons: [envelopeIcon],
      timestamp: timestamp,
      envelopeId: envelopeId,
    );
  }

  // Factory for multiple envelopes
  factory Activity.multipleEnvelopes({
    required ActivityType type,
    required List<String> envelopeNames,
    required List<String> envelopeIcons,
    required DateTime timestamp,
  }) {
    return Activity(
      type: type,
      envelopeNames: envelopeNames,
      envelopeIcons: envelopeIcons,
      timestamp: timestamp,
    );
  }

  // Get activity title
  String get title {
    switch (type) {
      case ActivityType.envelopeAdded:
        return envelopeNames.length == 1 
            ? 'Added ${envelopeNames.first} Envelope'
            : 'Added ${envelopeNames.length} Envelopes';
      case ActivityType.envelopeEdited:
        return 'Edited ${envelopeNames.first} Envelope';
      case ActivityType.envelopeDeleted:
        return envelopeNames.length == 1
            ? 'Deleted ${envelopeNames.first} Envelope'
            : 'Deleted ${envelopeNames.length} Envelopes';
    }
  }

  // Get color for activity type
  String get colorHex {
    switch (type) {
      case ActivityType.envelopeAdded:
        return 'FF4CAF50'; // Green
      case ActivityType.envelopeEdited:
        return 'FFFF9800'; // Orange
      case ActivityType.envelopeDeleted:
        return 'FFF44336'; // Red
    }
  }

  // Get time ago text
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  // Check if should be collapsible
  bool get isCollapsible {
    return (type == ActivityType.envelopeAdded || 
            type == ActivityType.envelopeDeleted) && 
           envelopeNames.length > 1;
  }
}