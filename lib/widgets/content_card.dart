import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/icerik.dart';
import '../utils/theme.dart';
import '../config/api_config.dart';

class ContentCard extends StatelessWidget {
  final Icerik icerik;
  final VoidCallback onTap;

  const ContentCard({super.key, required this.icerik, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final renk = AppTheme.kategoriRenk(icerik.kategoriSlug);
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Önemli banner
            if (icerik.onemli)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.priority_high, size: 14, color: Colors.red.shade700),
                    const SizedBox(width: 4),
                    Text('ÖNEMLİ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                  ],
                ),
              ),

            // Kapak resmi
            if (icerik.kapakResmi != null)
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: icerik.onemli ? Radius.zero : const Radius.circular(14),
                ),
                child: CachedNetworkImage(
                  imageUrl: '$baseUrl${icerik.kapakResmi}',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 180,
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 120,
                    color: renk.withValues(alpha: 0.08),
                    child: Center(child: Text(AppTheme.kategoriEmoji(icerik.kategoriSlug), style: const TextStyle(fontSize: 40))),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori + mahalle
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: renk.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          icerik.kategoriAd ?? '',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: renk),
                        ),
                      ),
                      if (icerik.mahalleAd != null) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.location_on, size: 12, color: AppTheme.textSecondary),
                        Text(icerik.mahalleAd!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                      const Spacer(),
                      Text(
                        timeago.format(
                          (icerik.yayinTarihi ?? icerik.createdAt).toLocal(),
                          locale: 'tr',
                        ),
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Başlık
                  Text(
                    icerik.baslik,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Özet
                  if (icerik.ozet != null && icerik.ozet!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      icerik.ozet!,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye_outlined, size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Text('${icerik.goruntulenme}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
