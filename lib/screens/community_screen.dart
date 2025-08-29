import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/layout_helpers.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: LayoutHelpers.getScreenPadding(context),
      child: LayoutHelpers.safeColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // Voice Forum Section
          _buildSectionHeader('Voice Forum', Icons.record_voice_over),
          
          _buildVoiceForumCard(
            context,
            'Rajesh Kumar',
            'Tomato leaf curl virus problem, please suggest solutions?',
            '2 hours ago',
            12,
          ),
          
          _buildVoiceForumCard(
            context,
            'Sunita Devi',
            'Need information about new wheat varieties.',
            '5 hours ago',
            8,
          ),
          
          // Q&A Section
          _buildSectionHeader('Q&A', Icons.question_answer),
          
          _buildQACard(
            context,
            'Q: Treatment for brown spot disease in rice?',
            'A: Spray Propiconazole 25% EC...',
            'Dr. Anil Sharma',
            '1 day ago',
            true,
          ),
          
          _buildQACard(
            context,
            'Q: How to make organic fertilizer?',
            'A: Mix cow dung, dry leaves and kitchen waste...',
            'Pramod Yadav',
            '3 days ago',
            false,
          ),
          
          // Expert Advice
          _buildSectionHeader('Expert Advice', Icons.person),
          
          _buildExpertCard(
            context,
            'Dr. Ram Prasad',
            'Agricultural Expert',
            'Crop disease and pest management',
            'online',
          ),
          
          _buildExpertCard(
            context,
            'Prof. Sunita Agrawal',
            'Soil Science Expert',
            'Soil fertility and nutrition',
            'offline',
          ),
          
          // Local Groups
          _buildSectionHeader('Local Groups', Icons.groups),
          
          _buildGroupCard(
            context,
            'Sonipat Farmers Union',
            '1,245 members',
            'Community of farmers from Haryana',
            true,
          ),
          
          _buildGroupCard(
            context,
            'Organic Farming Group',
            '892 members',
            'For natural farming practices',
            false,
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceForumCard(
    BuildContext context,
    String name,
    String question,
    String time,
    int replies,
  ) {
    return LayoutHelpers.responsiveCard(
      padding: const EdgeInsets.all(12),
      child: LayoutHelpers.safeColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          LayoutHelpers.responsiveRow(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutHelpers.safeColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    LayoutHelpers.safeText(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                    ),
                    LayoutHelpers.safeText(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_outline,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
            ],
          ),
          
          LayoutHelpers.safeText(
            question,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
          ),
          
          LayoutHelpers.responsiveRow(
            children: [
              Icon(
                Icons.reply,
                size: 14,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              LayoutHelpers.safeText(
                '$replies उत्तर',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQACard(
    BuildContext context,
    String question,
    String answer,
    String expertName,
    String time,
    bool isVerified,
  ) {
    return LayoutHelpers.responsiveCard(
      padding: const EdgeInsets.all(12),
      child: LayoutHelpers.safeColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.primaryGreen,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  expertName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified,
                  color: Colors.blue,
                  size: 16,
                ),
              ],
              const SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard(
    BuildContext context,
    String name,
    String title,
    String specialization,
    String status,
  ) {
    return LayoutHelpers.responsiveCard(
      padding: const EdgeInsets.all(12),
      child: LayoutHelpers.responsiveRow(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            child: Text(
              name[0],
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutHelpers.safeColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                LayoutHelpers.responsiveRow(
                  children: [
                    Flexible(
                      child: LayoutHelpers.safeText(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 14,
                    ),
                  ],
                ),
                LayoutHelpers.safeText(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                ),
                LayoutHelpers.safeText(
                  specialization,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: status == 'online' ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status == 'online' ? 'ऑनलाइन' : 'ऑफलाइन',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    String name,
    String members,
    String description,
    bool isJoined,
  ) {
    return LayoutHelpers.responsiveCard(
      padding: const EdgeInsets.all(12),
      child: LayoutHelpers.responsiveRow(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.groups,
              color: AppTheme.primaryGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutHelpers.safeColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                LayoutHelpers.safeText(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                ),
                LayoutHelpers.safeText(
                  members,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                ),
                LayoutHelpers.safeText(
                  description,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isJoined ? Colors.grey : AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: LayoutHelpers.safeText(
              isJoined ? 'छोड़ें' : 'जुड़ें',
              style: const TextStyle(fontSize: 11, color: Colors.white),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
