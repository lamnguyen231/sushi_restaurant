import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/sushi_nav_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SushiNavBar(),
      backgroundColor: AppTheme.eggshell,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Shisu Story Section
            _buildShisuStorySection(context),

            // Câu chuyện văn hóa Nhật Bản Section
            _buildCultureSection(context),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildShisuStorySection(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;
    
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shisu story',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.vermilion,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          'Sứ mệnh của Shisu khởi nguồn từ tình yêu mãnh liệt với tinh hoa văn hóa và ẩm thực Nhật Bản, cùng khát vọng chung tay kiến tạo nên chuỗi nhà hàng hải sản Nhật Bản cao cấp được tin yêu nhất tại Việt Nam. Đó là hành trình gieo mầm cho những giá trị tinh tế, tôn vinh sự giao hòa giữa hai nền văn hóa Việt – Nhật.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: AppTheme.ink.withOpacity(0.85),
            height: 1.8,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Lấy triết lý “Love.Fresh” làm kim chỉ nam, Shisu theo đuổi hai giá trị cốt lõi: “Love” – tình yêu sâu sắc với nghệ thuật ẩm thực và tinh thần Nhật Bản, cùng “Fresh” – cam kết tuyệt đối về chất lượng nguyên liệu thượng hạng. Điều này thể hiện ở mọi loại hải sản tại Shisu đều được vận chuyển bằng đường hàng không từ Nhật Bản về Việt Nam trong vòng 24 giờ.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            color: AppTheme.ink.withOpacity(0.85),
            height: 1.8,
          ),
        ),
      ],
    );

    final imageContent = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/ShisuStory.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 400,
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.image, size: 64)),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      color: AppTheme.rice.withOpacity(0.3),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: textContent),
                    const SizedBox(width: 80),
                    Expanded(flex: 5, child: imageContent),
                  ],
                )
              : Column(
                  children: [
                    textContent,
                    const SizedBox(height: 40),
                    imageContent,
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCultureSection(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Header
              Column(
                children: [
                  Icon(Icons.waves, color: AppTheme.vermilion, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'Câu chuyện văn hóa Nhật Bản',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.vermilion,
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 64),

              // Content Layout
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cột trái: Ảnh món ăn dọc + Text Menu theo mùa
                    Expanded(
                      flex: 4,
                      child: _buildCultureItem(
                        context,
                        title: 'Menu theo mùa',
                        text: 'Shisu tôn vinh triết lý “Shun” (旬) – nghệ thuật thưởng thức thực phẩm vào thời điểm tươi ngon nhất. Mỗi món ăn là một bức tranh chuyển mùa, nơi vị giác cảm nhận trọn vẹn hơi thở thiên nhiên, từ sắc xuân tinh khôi đến thu vàng dịu nhẹ.',
                        imagePath: 'assets/images/about1.png',
                        imageFirst: true,
                        imageHeight: 500,
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Cột phải: 2 hàng (Text - Ảnh)
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildCultureItemTextOnly(
                                  context,
                                  title: 'Tinh thần hiếu khách',
                                  text: 'Ở Shisu, Omotenashi (おもてなし) không chỉ là sự hiếu khách mà là tâm hồn của từng bữa ăn. Sự tận tâm, chỉn chu trong từng chi tiết, từ cách tiếp đón đến hương vị, cách bài trí tạo nên một trải nghiệm ẩm thực tròn đầy, trân quý từng thực khách.',
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset('assets/images/about3.png', fit: BoxFit.cover, height: 220),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset('assets/images/about2.png', fit: BoxFit.cover, height: 260),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildCultureItemTextOnly(
                                  context,
                                  title: 'Sự hài hòa của ẩm thực Nhật Bản',
                                  text: 'Từng món ăn tại Shisu là sự giao thoa giữa mỹ học và ẩm thực, tuân theo triết lý Washoku (和食), cân bằng hoàn hảo giữa sắc – hương – vị, giữa dinh dưỡng và sự tinh tế, mang đến một bản hòa ca của vị giác, nơi mọi giác quan đều được đánh thức.',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildCultureItem(
                      context,
                      title: 'Tinh thần hiếu khách',
                      text: 'Ở Shisu, Omotenashi (おもてなし) không chỉ là sự hiếu khách mà là tâm hồn của từng bữa ăn. Sự tận tâm, chỉn chu trong từng chi tiết, từ cách tiếp đón đến hương vị, cách bài trí tạo nên một trải nghiệm ẩm thực tròn đầy, trân quý từng thực khách.',
                      imagePath: 'assets/images/about2.png',
                      imageFirst: true,
                    ),
                    const SizedBox(height: 48),
                    _buildCultureItem(
                      context,
                      title: 'Sự hài hòa của ẩm thực Nhật Bản',
                      text: 'Từng món ăn tại Shisu là sự giao thoa giữa mỹ học và ẩm thực, tuân theo triết lý Washoku (和食), cân bằng hoàn hảo giữa sắc – hương – vị, giữa dinh dưỡng và sự tinh tế, mang đến một bản hòa ca của vị giác, nơi mọi giác quan đều được đánh thức.',
                      imagePath: 'assets/images/about3.png',
                      imageFirst: true,
                    ),
                    const SizedBox(height: 48),
                    _buildCultureItem(
                      context,
                      title: 'Menu theo mùa',
                      text: 'Shisu tôn vinh triết lý “Shun” (旬) – nghệ thuật thưởng thức thực phẩm vào thời điểm tươi ngon nhất. Mỗi món ăn là một bức tranh chuyển mùa, nơi vị giác cảm nhận trọn vẹn hơi thở thiên nhiên, từ sắc xuân tinh khôi đến thu vàng dịu nhẹ.',
                      imagePath: 'assets/images/about1.png',
                      imageFirst: true,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCultureItemTextOnly(
    BuildContext context, {
    required String title,
    required String text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.ink,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: AppTheme.ink.withOpacity(0.85),
              ),
        ),
      ],
    );
  }

  Widget _buildCultureItem(
    BuildContext context, {
    required String title,
    required String text,
    required String imagePath,
    required bool imageFirst,
    double? imageHeight,
  }) {
    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: imageHeight,
        errorBuilder: (_, __, ___) => Container(
          height: imageHeight ?? 250,
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.image)),
        ),
      ),
    );

    final textWidget = _buildCultureItemTextOnly(context, title: title, text: text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageFirst) ...[
          imageWidget,
          const SizedBox(height: 24),
          textWidget,
        ] else ...[
          textWidget,
          const SizedBox(height: 24),
          imageWidget,
        ],
      ],
    );
  }
}
