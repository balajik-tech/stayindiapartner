import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/razorpay_payment_result.dart';
import '../bloc/razorpay_cubit.dart';
import '../bloc/razorpay_state.dart';

class RazorpayPaymentScreen extends StatefulWidget {
  final String apiKey;
  final int amount;
  final String name;
  final String orderId;
  final String? description;
  final String? email;
  final String? contact;
  final String? prefillName;
  final Function(RazorpayPaymentResult)? onSuccess;
  final Function(String)? onFailure;

  const RazorpayPaymentScreen({
    super.key,
    required this.apiKey,
    required this.amount,
    required this.name,
    required this.orderId,
    this.description,
    this.email,
    this.contact,
    this.prefillName,
    this.onSuccess,
    this.onFailure,
  });

  @override
  State<RazorpayPaymentScreen> createState() => _RazorpayPaymentScreenState();
}

class _RazorpayPaymentScreenState extends State<RazorpayPaymentScreen> {
  late RazorpayCubit _cubit;
  bool _checkoutInitiated = false;

  @override
  void initState() {
    super.initState();
    _cubit = sl<RazorpayCubit>();

    // Delayed initiation to ensure the screen is fully transitioned
    // and avoid activity conflicts on Android.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && !_checkoutInitiated) {
        _startCheckout();
      }
    });
  }

  void _startCheckout() {
    setState(() {
      _checkoutInitiated = true;
    });

    try {
      _cubit.openCheckout(
        apiKey: widget.apiKey,
        amount: widget.amount,
        name: widget.name,
        orderId: widget.orderId,
        description: widget.description,
        email: widget.email,
        contact: widget.contact,
      );
    } catch (e) {
      debugPrint("Razorpay UI Error: $e");
      if (mounted) {
        if (widget.onFailure != null) {
          widget.onFailure!(e.toString());
        } else {
          Navigator.pop(context, "payment.launch_error".tr(args: [e.toString()]));
        }
      }
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<RazorpayCubit, RazorpayState>(
        listener: (context, state) {
          if (state is RazorpaySuccess) {
            if (widget.onSuccess != null) {
              widget.onSuccess!(state.result);
            } else {
              Navigator.pop(context, state.result);
            }
          } else if (state is RazorpayFailure) {
            if (widget.onFailure != null) {
              widget.onFailure!(state.message);
            } else {
              Navigator.pop(context, state.message);
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text('payment.secure_payment_title'.tr()),
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    state is RazorpayOpeningCheckout || !_checkoutInitiated
                        ? 'payment.connecting_secure_gateway'.tr()
                        : 'payment.awaiting_payment_result'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'payment.dont_close_screen_note'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (state is RazorpayFailure) ...[
                    const SizedBox(height: 20),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
