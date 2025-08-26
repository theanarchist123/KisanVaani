import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class FieldManagementSection extends StatefulWidget {
  const FieldManagementSection({super.key});

  @override
  State<FieldManagementSection> createState() => _FieldManagementSectionState();
}

class _FieldManagementSectionState extends State<FieldManagementSection> {
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildManagementCard(
          0,
          '💧',
          'Irrigation Schedule',
          'Next irrigation: Tomorrow 6:00 AM',
          _buildIrrigationContent(),
        ),
        
        const SizedBox(height: 12),
        
        _buildManagementCard(
          1,
          '🧪',
          'Fertilizer & Manure',
          'Time for NPK fertilizer',
          _buildFertilizerContent(),
        ),
        
        const SizedBox(height: 12),
        
        _buildManagementCard(
          2,
          '🐛',
          'Pest Control',
          'Last spray: 5 days ago',
          _buildPestControlContent(),
        ),
        
        const SizedBox(height: 12),
        
        _buildManagementCard(
          3,
          '📅',
          'Crop Calendar',
          'This month\'s activities',
          _buildHarvestCalendarContent(),
        ),
      ],
    );
  }

  Widget _buildManagementCard(
    int index,
    String emoji,
    String title,
    String subtitle,
    Widget content,
  ) {
    final isExpanded = _expandedIndex == index;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedIndex = isExpanded ? -1 : index;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: isExpanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: content,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildIrrigationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 12),
        
        const Text(
          'Upcoming Irrigation',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        
        const SizedBox(height: 8),
        
        _buildScheduleItem('कल सुबह 6:00', 'टमाटर - 2 एकड़', true),
        _buildScheduleItem('कल शाम 5:00', 'गेहूं - 3 एकड़', true),
        _buildScheduleItem('2 दिन बाद', 'प्याज - 0.5 एकड़', false),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.water_drop, size: 18),
                label: const Text('Start Irrigation Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.schedule, size: 18),
                label: const Text('समय बदलें'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFertilizerContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 12),
        
        _buildFertilizerCard('NPK (19:19:19)', 'टमाटर के लिए', 'आज', true),
        _buildFertilizerCard('यूरिया', 'गेहूं के लिए', '3 दिन बाद', false),
        _buildFertilizerCard('जैविक खाद', 'सभी फसलों के लिए', '1 सप्ताह बाद', false),
        
        const SizedBox(height: 16),
        
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('खाद रिकॉर्ड जोड़ें'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }

  Widget _buildPestControlContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 12),
        
        _buildPestControlCard('फंगीसाइड स्प्रे', 'टमाटर', '5 दिन पहले', Colors.green),
        _buildPestControlCard('इंसेक्टिसाइड', 'गेहूं', '10 दिन पहले', Colors.orange),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.accentOrange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning,
                color: AppTheme.accentOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'टमाटर में पत्ती मोड़क कीट दिखाई दे रहा है',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accentOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.camera_alt, size: 18),
          label: const Text('फोटो से जांच करें'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }

  Widget _buildHarvestCalendarContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 12),
        
        const Text(
          'अगले 30 दिनों की गतिविधियां',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        
        const SizedBox(height: 12),
        
        _buildCalendarItem('15 दिन बाद', 'गेहूं की दूसरी सिंचाई', Icons.water_drop),
        _buildCalendarItem('25 दिन बाद', 'टमाटर में फूल आना शुरू', Icons.local_florist),
        _buildCalendarItem('30 दिन बाद', 'प्याज की रोपाई', Icons.agriculture),
        _buildCalendarItem('45 दिन बाद', 'गेहूं की कटाई', Icons.content_cut),
        
        const SizedBox(height: 16),
        
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.calendar_month, size: 18),
          label: const Text('पूरा कैलेंडर देखें'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryGreen,
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(String time, String crop, bool isToday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday 
          ? AppTheme.primaryGreen.withOpacity(0.1)
          : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday 
            ? AppTheme.primaryGreen.withOpacity(0.3)
            : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: isToday ? AppTheme.primaryGreen : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isToday ? AppTheme.primaryGreen : AppTheme.textDark,
                  ),
                ),
                Text(
                  crop,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerCard(String name, String crop, String time, bool isDue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDue 
          ? AppTheme.accentOrange.withOpacity(0.1)
          : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDue 
            ? AppTheme.accentOrange.withOpacity(0.3)
            : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isDue ? AppTheme.accentOrange : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$crop • $time',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPestControlCard(String treatment, String crop, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  treatment,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$crop • $time',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarItem(String time, String activity, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
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
