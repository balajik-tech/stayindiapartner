import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/razorpay_payment_result.dart';
import '../bloc/razorpay_cubit.dart';
import '../bloc/razorpay_state.dart';

class RazorpayPaymentScreen extends StatelessWidget {
  final String apiKey;
  final int amount;
  final String name;
  final String orderId;
  final String? description;
  final String? email;
  final String? contact;
  final Function(RazorpayPaymentResult) onSuccess;
  final Function(String) onFailure;

  const RazorpayPaymentScreen({
    super.key,
    required this.apiKey,
    required this.amount,
    required this.name,
    required this.orderId,
    this.description,
    this.email,
    this.contact,
    required this.onSuccess,
    required this.onFailure,
  });

  void _onPayPressed(BuildContext context) {
    context.read<RazorpayCubit>().openCheckout(
          apiKey: apiKey,
          amount: amount,
          name: name,
          orderId: orderId,
          description: description,
          email: email,
          contact: contact,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // return BlocConsumer<RazorpayCubit, RazorpayState>(
    //   listener: (context, state) {
    //     debugPrint("RazorpayPaymentScreen Listener: State is ${state.runtimeType}");
    //     if (state is RazorpaySuccess) {
    //       debugPrint("RazorpayPaymentScreen: Success event triggering onSuccess");
    //       onSuccess(state.result);
    //     } else if (state is RazorpayFailure) {
    //       debugPrint("RazorpayPaymentScreen: Failure event triggering onFailure. Message: ${state.message}");
    //       onFailure(state.message);
    //     }
    //   },
    //   builder: (context, state) {
    //     return Scaffold(
    //       appBar: AppBar(
    //         title: const Text('Razorpay Payment'),
    //         centerTitle: true,
    //       ),
    //       body: Container(
    //         width: double.infinity,
    //         padding: const EdgeInsets.all(24.0),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             if (state is RazorpayOpeningCheckout) ...[
    //               const CircularProgressIndicator(),
    //               const SizedBox(height: 24),
    //               const Text(
    //                 'Opening Secure Payment Gateway...',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    //               ),
    //             ] else if (state is RazorpayFailure) ...[
    //               const Icon(Icons.error_outline, color: Colors.red, size: 72),
    //               const SizedBox(height: 16),
    //               const Text(
    //                 'Payment Failed',
    //                 style: TextStyle(
    //                     fontSize: 22,
    //                     fontWeight: FontWeight.bold,
    //                     color: Colors.red),
    //               ),
    //               const SizedBox(height: 8),
    //               Text(
    //                 state.message,
    //                 textAlign: TextAlign.center,
    //                 style: const TextStyle(fontSize: 14, color: Colors.black54),
    //               ),
    //               if (state.code != null) ...[
    //                 const SizedBox(height: 4),
    //                 Text(
    //                   'Error Code: ${state.code}',
    //                   style: const TextStyle(fontSize: 12, color: Colors.grey),
    //                 ),
    //               ],
    //               const SizedBox(height: 32),
    //               ElevatedButton(
    //                 onPressed: () => _onPayPressed(context),
    //                 style: ElevatedButton.styleFrom(
    //                   backgroundColor: Colors.blue,
    //                   minimumSize: const Size(double.infinity, 50),
    //                   shape: RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(12)),
    //                 ),
    //                 child: const Text('Try Again',
    //                     style: TextStyle(color: Colors.white, fontSize: 16)),
    //               ),
    //               const SizedBox(height: 12),
    //               TextButton(
    //                 onPressed: () => Navigator.pop(context),
    //                 child: const Text('Cancel'),
    //               ),
    //             ] else ...[
    //               const Icon(Icons.security, color: Colors.green, size: 72),
    //               const SizedBox(height: 24),
    //               Text(
    //                 'Pay ₹${(amount / 100).toStringAsFixed(2)}',
    //                 style: const TextStyle(
    //                     fontSize: 24, fontWeight: FontWeight.bold),
    //               ),
    //               const SizedBox(height: 8),
    //               Text(
    //                 'Order ID: ${orderId.isNotEmpty ? orderId : "Standard Checkout"}',
    //                 style: const TextStyle(color: Colors.grey),
    //               ),
    //               const SizedBox(height: 32),
    //               ElevatedButton(
    //                 onPressed: () => _onPayPressed(context),
    //                 style: ElevatedButton.styleFrom(
    //                   backgroundColor: Colors.blue,
    //                   minimumSize: const Size(double.infinity, 50),
    //                   shape: RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(12)),
    //                 ),
    //                 child: const Text('Pay Now',
    //                     style: TextStyle(color: Colors.white, fontSize: 16)),
    //               ),
    //             ],
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}
