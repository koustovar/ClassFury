import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/features/batches/data/models/batch_model.dart';
import 'package:classfury/features/materials/presentation/bloc/materials_cubit.dart';
import 'package:classfury/features/materials/presentation/bloc/materials_state.dart';
import 'package:classfury/features/materials/data/repositories/materials_repository_impl.dart';

class BatchMaterialsPage extends StatelessWidget {
  final BatchModel batch;
  const BatchMaterialsPage({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaterialsCubit(getIt<MaterialsRepository>())..loadBatchMaterials(batch.id),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${batch.name} - Materials'),
        ),
        body: BlocBuilder<MaterialsCubit, MaterialsState>(
          builder: (context, state) {
            if (state is MaterialsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MaterialsError) {
              return Center(child: Text(state.message));
            } else if (state is MaterialsLoaded) {
              if (state.materials.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_outlined, size: 64, color: Theme.of(context).hintColor),
                      const Gap(16),
                      Text(
                        'No materials uploaded yet', 
                        style: AppTypography.bodyLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.materials.length,
                separatorBuilder: (_, __) => const Gap(16),
                itemBuilder: (context, index) {
                  final material = state.materials[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          material.fileName.toLowerCase().endsWith('.pdf')
                              ? Icons.picture_as_pdf
                              : Icons.insert_drive_file,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        material.title, 
                        style: AppTypography.title.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (material.description.isNotEmpty) ...[
                            const Gap(4),
                            Text(
                              material.description, 
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                          const Gap(8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: Theme.of(context).hintColor),
                              const Gap(4),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(material.createdAt),
                                style: AppTypography.bodySmall.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.download_rounded),
                        onPressed: () => launchUrl(Uri.parse(material.fileUrl)),
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
