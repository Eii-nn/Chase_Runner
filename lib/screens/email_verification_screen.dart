import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  int _resendTimer = 60;
  late Timer _resendCountdownTimer;
  bool _isLoading = false;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animation for the icon
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimationController.repeat(reverse: true);

    // Check if the email is already verified
    final authService = Provider.of<AuthService>(context, listen: false);
    _isEmailVerified = authService.isEmailVerified;

    // If not already verified, periodically check if verification completed
    if (!_isEmailVerified) {
      _timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _checkEmailVerification(),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    if (_canResendEmail == false) {
      _resendCountdownTimer.cancel();
    }
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailVerification() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final isVerified = await authService.checkEmailVerified();

    if (isVerified) {
      setState(() {
        _isEmailVerified = true;
      });

      _timer.cancel();

      // Navigate to home screen after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthService>(context, listen: false)
          .sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent! Check your inbox.'),
          backgroundColor: Colors.green,
        ),
      );

      // Start cooldown for resend button
      setState(() {
        _canResendEmail = false;
        _resendTimer = 60;
        _isLoading = false;
      });

      _resendCountdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            if (_resendTimer > 0) {
              _resendTimer--;
            } else {
              _canResendEmail = true;
              timer.cancel();
            }
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send verification email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmailVerified) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Email verified!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Redirecting to home...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE0E0E0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated email icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread,
                    size: 60,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title and instructions
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'We\'ve sent a verification email to your email address. Please check your inbox and click the verification link to activate your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you don\'t see the email, check your spam folder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),

              // Resend button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canResendEmail && !_isLoading
                      ? _resendVerificationEmail
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          _canResendEmail
                              ? 'Resend Verification Email'
                              : 'Resend in $_resendTimer seconds',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Already verified button
              OutlinedButton(
                onPressed: _checkEmailVerification,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  side: const BorderSide(color: Color(0xFF1976D2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'I\'ve already verified',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Check status
              const Text(
                'Checking verification status...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
