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
          _buildSectionHeader('आवाज़ मंच', Icons.record_voice_over),
          
          _buildVoiceForumCard(
            context,
            'राजेश कुमार',
            'टमाटर पत्ती कर्ल वायरस की समस्या, कृपया समाधान सुझाएं?',
            '2 घंटे पहले',
            12,
          ),
          
          _buildVoiceForumCard(
            context,
            'सुनीता देवी',
            'गेहूं की नई किस्मों के बारे में जानकारी चाहिए।',
            '5 घंटे पहले',
            8,
          ),
          
          // Q&A Section
          _buildSectionHeader('प्रश्न उत्तर', Icons.question_answer),
          
          _buildQACard(
            context,
            'प्रश्न: चावल में ब्राउन स्पॉट रोग का इलाज?',
            'उत्तर: प्रोपिकोनाज़ोल 25% EC का छिड़काव करें...',
            'डॉ. अनिल शर्मा',
            '1 दिन पहले',
            true,
          ),
          
          _buildQACard(
            context,
            'प्रश्न: जैविक खाद कैसे बनाएं?',
            'उत्तर: गोबर, सूखे पत्ते और रसोई का कचरा मिलाएं...',
            'प्रमोद यादव',
            '3 दिन पहले',
            false,
          ),
          
          // Expert Advice
          _buildSectionHeader('विशेषज्ञ सलाह', Icons.person),
          
          _buildExpertCard(
            context,
            'डॉ. राम प्रसाद',
            'कृषि विशेषज्ञ',
            'फसल रोग और कीट प्रबंधन',
            'online',
          ),
          
          _buildExpertCard(
            context,
            'प्रो. सुनीता अग्रवाल',
            'मृदा विज्ञान विशेषज्ञ',
            'मिट्टी की उर्वरता और पोषण',
            'offline',
          ),
          
          // Local Groups
          _buildSectionHeader('स्थानीय समूह', Icons.groups),
          
          _buildGroupCard(
            context,
            'सोनीपत किसान संघ',
            '1,245 सदस्य',
            'हरियाणा के किसानों का समुदाय',
            true,
          ),
          
          _buildGroupCard(
            context,
            'जैविक खेती समूह',
            '892 सदस्य',
            'प्राकृतिक खेती प्रथाओं के लिए',
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
