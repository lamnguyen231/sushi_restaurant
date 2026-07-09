import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/sushi_nav_bar.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SushiNavBar(),
      backgroundColor: AppTheme.eggshell,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 800, // Fixed width for desktop, adaptable on mobile
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            color: AppTheme.paper, // Changed to a clean white card
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bản đồ (cột dọc, nằm trên phần thông tin)
                SizedBox(
                  height: 450,
                  width: double.infinity,
                  child: kIsWeb
                      ? HtmlElementView.fromTagName(
                          tagName: 'iframe',
                          onElementCreated: (dynamic element) {
                            element.setAttribute('src',
                                'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3370.484141599341!2d105.52271427471398!3d21.012421688340616!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3135abc60e7d3f19%3A0x2be9d7d0b5abcbf4!2zVHLGsOG7nW5nIMSQ4bqhaSBo4buNYyBGUFQgSMOgIE7hu5lp!5e1!3m2!1svi!2s!4v1783595678463!5m2!1svi!2s');
                            element.setAttribute('style',
                                'border:0; width: 100%; height: 100%;');
                            element.setAttribute('allowfullscreen', '');
                            element.setAttribute('loading', 'lazy');
                            element.setAttribute('referrerpolicy',
                                'strict-origin-when-cross-origin');
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              'Bản đồ chỉ hỗ trợ hiển thị trực tiếp trên Web.\n(Mã nguồn Native cần plugin Google Maps)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),

                // Phần thông tin liên hệ bên dưới
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 32,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(width: 60, height: 2, color: AppTheme.ink),
                      const SizedBox(height: 48),

                      _buildInfoSection(
                        context,
                        title: 'Địa chỉ của chúng tôi',
                        content:
                            'Trường Đại học FPT Hà Nội, Khu Công Nghệ Cao Hòa Lạc, CT03, Hòa Lạc, Hà Nội, Việt Nam',
                      ),
                      const SizedBox(height: 32),

                      _buildInfoSection(
                        context,
                        title: 'Email của chúng tôi',
                        content: 'shisuoishi@gmail.com',
                      ),
                      const SizedBox(height: 32),

                      _buildInfoSection(
                        context,
                        title: 'Điện thoại',
                        content: '01234.56899',
                      ),
                      const SizedBox(height: 32),

                      _buildInfoSection(
                        context,
                        title: 'Thời gian làm việc',
                        content: 'Thứ 2 đến Chủ Nhật từ 10h đến 21h',
                      ),

                      const SizedBox(height: 64),
                      Center(
                        child: Text(
                          '-- Chúc quý khách có trải nghiệm thật tốt tại Shisu Restaurant. Xin cảm ơn! --',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.mutedInk,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF888888),
                fontSize: 14,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.5,
              ),
        ),
      ],
    );
  }
}
