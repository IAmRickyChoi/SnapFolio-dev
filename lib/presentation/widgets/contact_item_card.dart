import 'package:flutter/material.dart';
import 'dart:math' show min;
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';

class ContactItemCard extends StatefulWidget {
  final Contact contact;
  final ContactRepository repository;
  final VoidCallback onTap;

  const ContactItemCard({
    super.key,
    required this.contact,
    required this.repository,
    required this.onTap,
  });

  @override
  State<ContactItemCard> createState() => _ContactItemCardState();
}

class _ContactItemCardState extends State<ContactItemCard> {
  late Future<List<String>> _galleryFuture;

  @override
  void initState() {
    super.initState();
    _galleryFuture = widget.repository.getGalleryPhotos(widget.contact.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        child: SizedBox(
          height: 140, // Fixed height for the card
          child: Row(
            children: [
              // Left side: Large Profile Picture
              Container(
                width: 120, // Adjust width as needed
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: widget.contact.profileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.contact.profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.contact.profileImageUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              // Right side: Contact details and gallery preview
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              widget.contact.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Chip(
                            avatar: const Icon(
                              Icons.photo_library_outlined,
                              size: 16,
                            ),
                            label: Text(widget.contact.photoCount.toString()),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Birth: ${widget.contact.age} / Tag: ${widget.contact.tag}",
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Gallery Preview
                      Expanded(
                        // Use Expanded to make FutureBuilder fill available height
                        child: FutureBuilder<List<String>>(
                          future: _galleryFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            final photos = snapshot.data ?? [];
                            if (photos.isEmpty) {
                              return const Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  'No photos yet.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return _buildResponsiveGrid(photos);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(List<String> photos) {
    int photoCount = photos.length;
    int totalCount = widget.contact.photoCount;

    if (photoCount == 0) return const SizedBox();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double circleDiameter = 44.0;
        const double overlap =
            28.0; // How much each circle overlaps the previous one

        final double availableWidth = constraints.maxWidth;

        // Calculate how many circles can fit
        int maxPossibleFitCount =
            1 + ((availableWidth - circleDiameter) / overlap).floor();
        int displayCount = min(photoCount, maxPossibleFitCount);
        if (displayCount <= 0) return const SizedBox.shrink();

        return SizedBox(
          height: circleDiameter,
          width: (displayCount - 1) * overlap + circleDiameter,
          child: Stack(
            children: List.generate(displayCount, (index) {
              bool isLastItem = index == displayCount - 1;
              bool showOverlay = isLastItem && (totalCount > displayCount);
              int plusNumber = totalCount - displayCount;

              return Positioned(
                left: index * overlap,
                child: Container(
                  width: circleDiameter,
                  height: circleDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(photos[index]),
                    child: showOverlay
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.6),
                            ),
                            child: Center(
                              child: Text(
                                "+$plusNumber",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
