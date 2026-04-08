import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:classfury/app/theme/app_typography.dart';
import 'package:classfury/core/services/payment_service.dart';
import 'package:classfury/core/di/injection.dart';
import 'package:classfury/features/auth/domain/entities/user_entity.dart';
import 'package:classfury/features/auth/presentation/bloc/auth_bloc.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Upgrade'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 60),
                    const Gap(20),
                    const Text(
                      'Sign in to upgrade to premium and unlock all features.',
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upgrade to ClassFury Premium',
                    style: AppTypography.h2.copyWith(
                        color: Theme.of(context).colorScheme.onSurface)),
                const Gap(12),
                Text(
                  'Enjoy unlimited classes, advanced analytics, priority support, and more.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(24),
                if (state.user.isPremium) ...[
                  _buildPremiumStatusCard(context, state.user),
                ] else ...[
                  _buildOfferCard(context),
                  const Gap(24),
                  _buildBenefitItem(
                      context, Icons.school_outlined, 'Unlimited classes'),
                  _buildBenefitItem(
                      context, Icons.insights_outlined, 'Advanced analytics'),
                  _buildBenefitItem(context, Icons.support_agent_outlined,
                      'Priority support'),
                  _buildBenefitItem(context, Icons.cloud_upload_outlined,
                      'Faster batch sync'),
                  const Gap(36),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _startPurchase(context, state.user),
                      icon: const Icon(Icons.star_outline),
                      label: const Text('Upgrade for ₹299'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Premium subscription',
              style: AppTypography.title.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              )),
          const Gap(12),
          Text('Monthly access for all premium features.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )),
          const Gap(20),
          Text('₹299 / month',
              style: AppTypography.h2.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _buildPremiumStatusCard(BuildContext context, UserEntity user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 28),
              const Gap(12),
              Text('Premium Active',
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          const Gap(12),
          Text('Thank you for upgrading to ClassFury Premium.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              )),
          if (user.premiumSince != null) ...[
            const Gap(12),
            Text(
                "Premium since ${user.premiumSince!.toLocal().toString().split(' ').first}",
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const Gap(12),
          Expanded(
            child: Text(label,
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                )),
          ),
        ],
      ),
    );
  }

  void _startPurchase(BuildContext context, UserEntity user) {
    final paymentService = getIt<PaymentService>();
    final razorpayKey = dotenv.env['RAZORPAY_KEY'] ?? 'rzp_test_your_key_here';

    paymentService.setCallbacks(
      onSuccess: (response) {
        context.read<AuthBloc>().add(UpdatePremiumStatusRequested(
              uid: user.uid,
              isPremium: true,
            ));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Payment successful! You are now premium.')),
        );
      },
      onError: (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${response.message}')),
        );
      },
      onWallet: (response) {
        debugPrint('External wallet selected: ${response.walletName}');
      },
    );

    paymentService.openCheckout(
      key: razorpayKey,
      amount: 299.0,
      name: 'ClassFury Premium',
      description: 'Monthly Premium Subscription',
      orderId: 'premium_${DateTime.now().millisecondsSinceEpoch}',
      prefillEmail: user.email,
      prefillContact: user.phoneNumber,
    );
  }
}
