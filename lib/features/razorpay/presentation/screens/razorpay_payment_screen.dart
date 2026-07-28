import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final Function(RazorpaySuccess) onSuccess;
  final Function(RazorpayFailure) onFailure;

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<RazorpayCubit, RazorpayState>(
      listener: (context, state) {
        if (state is RazorpaySuccess) {
          onSuccess(state);
        } else if (state is RazorpayFailure) {
          onFailure(state);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Proceeding to payment...'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<RazorpayCubit>().openCheckout(
                        apiKey: apiKey,
                        amount: amount,
                        name: name,
                        orderId: orderId,
                        description: description,
                        email: email,
                        contact: contact,
                      );
                },
                child: const Text('Pay Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
