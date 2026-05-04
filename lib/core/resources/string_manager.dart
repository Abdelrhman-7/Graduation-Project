class AppStrings {
  static const String welcome = 'Welcome to MedDoc';
  static const String authChoiceDesc =
      'Your health journey starts here. Please choose how you want to proceed.';
  static const String login = 'Login';
  static const String register = 'Register';

  // Login
  static const String welcomeBack = 'Welcome Back!';
  static const String loginDescPatient =
      'Sign in to access your appointments and medical records.';
  static const String loginDescProvider =
      'Sign in to manage your schedule and patients.';
  static const String password = 'Password';
  static const String passwordHint = '••••••••';
  static const String forgotPassword = 'Forgot Password?';
  static const String forgotPasswordTitle = 'Forgot Password?';
  static const String forgotPasswordSubtitle = 'Enter your email address and we will send you a link to reset your password.';
  static const String resetPassword = 'Reset Password';
  static const String backToLogin = 'Back to Login';
  static const String dontHaveAccount = 'Don\'t have an account? ';
  // Role Selection
  static const String joinAs = 'Join as a...';
  static const String chooseRole =
      'Choose your role to get started with your\nhealthcare journey.';
  static const String patient = 'Patient';
  static const String patientDesc = 'Find doctors &\nbook\nappointments';
  static const String doctor = 'Doctor';
  static const String doctorDesc = 'Manage patients\n& schedule';
  static const String continueBtn = 'Continue';

  static const String step1Of2 = 'Step 1 of 2';
  static const String completed50 = '50% Completed';
  static const String step2Of2 = 'Step 2 of 2';
  static const String completed100 = '100% Completed';
  static const String patientRegistration = 'Patient Registration';
  static const String patientRegistrationDesc =
      'Please fill in your details to connect with\ndoctors and pharmacies.';
  static const String completeYourProfile = 'Complete Your Profile';
  static const String completeYourProfileDesc =
      'Just a few more details to secure your MedLink\naccount.';

  static const String providerRegistration = 'Provider Registration';
  static const String joinAsProvider = 'Join as a Provider';
  static const String providerRegistrationDesc =
      'Please provide your professional details for\nverification.';

  // Form fields (Patient)
  static const String fullName = 'Full Name';
  static const String fullNameHint = 'Jane Doe';
  static const String emailAddress = 'Email Address';
  static const String emailHint = 'jane@example.com';
  static const String dateOfBirth = 'Date of Birth';
  static const String age = 'Age';
  static const String ageHint = 'Enter your age';
  static const String gender = 'Gender';
  static const String genderHint = 'Select your gender';

  // Form fields (Provider)
  static const String providerEmailHint = 'e.g., john@example.com';
  static const String specialization = 'Specialization';
  static const String specializationHint = 'Select your specialty';
  static const String medicalLicense = 'Medical License Number';
  static const String medicalLicenseHint = 'e.g., MD-12345678';
  static const String yearsOfExperience = 'Years of Experience';
  static const String yearsOfExperienceHint = '0';
  static const String years = 'Years';

  // Security
  static const String securitySettings = 'Security Settings';
  static const String createPassword = 'Create Password';
  static const String createPasswordHint = 'At least 8 characters';
  static const String confirmPassword = 'Confirm Password';
  static const String confirmPasswordHint = 'Repeat your password';
  static const String rule8Chars = 'At least 8 characters';
  static const String ruleNumber = 'Include a number';
  static const String ruleSpecialChar = 'Include a special character';

  // Medical History
  static const String medicalHistory = 'Medical History';
  static const String knownAllergies = 'Known Allergies';
  static const String chronicConditions = 'Chronic Conditions';
  static const String otherNotes = 'Other Notes';
  static const String otherNotesHint =
      'Please list any other relevant medical\nhistory...';

  // Buttons & Links
  static const String createAccount = 'Create Account';
  static const String completeRegistration = 'Complete Registration';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String termsAgreeText =
      'By clicking "Complete Registration", you agree to MedLink\'s ';
  static const String termsOfService = 'Terms of Service';
  static const String andText = ' and ';
  static const String privacyPolicy = 'Privacy Policy';
  static const String add = 'Add';
}
