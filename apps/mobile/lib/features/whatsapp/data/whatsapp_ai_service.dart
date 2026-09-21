class WhatsAppAiService {
  const WhatsAppAiService._();
  static const instance = WhatsAppAiService._();

  /// Formats any raw or draft text into a professional WhatsApp formatted notice
  String polishAndFormat(
    String rawText, {
    String adminNumber = '7388389944',
    String libraryName = 'Chintamani Library',
  }) {
    final clean = rawText.trim();
    if (clean.isEmpty) {
      return '*📚 $libraryName • OFFICIAL NOTICE*\n\n'
          'Dear Scholar,\n\n'
          'Kindly note this important communication from library administration.\n\n'
          '• Please maintain decorum & discipline inside premises\n'
          '• For renewals & queries, contact desk\n\n'
          '📞 *Admin Contact:* +91 $adminNumber\n'
          '_Best wishes for your studies!_';
    }

    final buffer = StringBuffer();
    buffer.writeln('*📚 $libraryName • IMPORTANT NOTICE*');
    buffer.writeln();
    buffer.writeln('Dear Student / Scholar,');
    buffer.writeln();

    // Split text into paragraphs and format with bullet points
    final lines = clean.split('\n').where((l) => l.trim().isNotEmpty).toList();
    for (final line in lines) {
      final t = line.trim();
      if (t.startsWith('•') || t.startsWith('-') || t.startsWith('*')) {
        buffer.writeln('• *${t.replaceFirst(RegExp(r'^[•\-\*]\s*'), '')}*');
      } else {
        buffer.writeln('• $t');
      }
    }

    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📞 *Helpline / Admin:* +91 $adminNumber');
    buffer.writeln('_Warm regards,_\n*$libraryName Administration*');
    return buffer.toString();
  }

  /// Transforms text into a polite, respectful scholarly tone
  String makePolite(
    String rawText, {
    String adminNumber = '7388389944',
    String libraryName = 'Chintamani Library',
  }) {
    final clean = rawText.trim();
    return '*📚 $libraryName • POLITE REMINDER*\n\n'
        'Dear Scholar,\n\n'
        'Greetings from $libraryName! We hope your studies and exam preparation are going wonderful.\n\n'
        '${clean.isNotEmpty ? "We kindly request your attention regarding:\n• $clean\n\n" : ""}'
        'Kindly visit the front desk or connect via WhatsApp for any assistance or seat renewals.\n\n'
        '📞 *Admin Helpline:* +91 $adminNumber\n'
        '_Wishing you great focus and success!_\n'
        '*— $libraryName Team*';
  }

  /// Transforms text into an urgent, official time-sensitive notice
  String makeUrgent(
    String rawText, {
    String adminNumber = '7388389944',
    String libraryName = 'Chintamani Library',
  }) {
    final clean = rawText.trim();
    return '🚨 *URGENT NOTICE • TIME-SENSITIVE*\n'
        '*🏛️ $libraryName Management*\n\n'
        'Dear Student,\n\n'
        'This is an *URGENT & FINAL* administrative reminder:\n\n'
        '${clean.isNotEmpty ? "⚠️ *$clean*\n\n" : "⚠️ *Your library membership & seat allocation require immediate action.*\n\n"}'
        '• Final 12-hour grace period is active\n'
        '• Unresolved dues may result in automated seat release\n'
        '• Please clear dues immediately to continue access\n\n'
        '━━━━━━━━━━━━━━━━━━━━\n'
        '📲 *Direct WhatsApp / Call:* +91 $adminNumber\n'
        '⚠️ *Action required within 12 Hours*';
  }

  /// Transforms text into a bilingual Hindi & English formatted notice
  String makeBilingualHindi(
    String rawText, {
    String adminNumber = '7388389944',
    String libraryName = 'Chintamani Library',
  }) {
    final clean = rawText.trim();
    return '*📚 चिंतामणि लाइब्रेरी ($libraryName) • आवश्यक सूचना*\n\n'
        'प्रिय छात्र/छात्रा (Dear Student),\n\n'
        'सादर अभिवादन। पुस्तकालय प्रबंधन की ओर से सूचित किया जाता है:\n\n'
        '${clean.isNotEmpty ? "📌 *$clean*\n\n" : ""}'
        '• कृपया समय पर शुल्क एवं सीट नवीनीकरण कराएं\n'
        '• अध्ययन कक्ष में पूर्ण शांति बनाए रखें\n'
        '• किसी भी समस्या के लिए हेल्पडेस्क से संपर्क करें\n\n'
        '━━━━━━━━━━━━━━━━━━━━\n'
        '📞 *संपर्क सूत्र (Helpline):* +91 $adminNumber\n'
        '_आपके उज्ज्वल भविष्य एवं सफलता की शुभकामनाएँ!_\n'
        '*प्रबंधन, $libraryName*';
  }

  /// Generates a complete notice based on user prompt or topic
  String generateFromTopic(
    String topic, {
    String adminNumber = '7388389944',
    String libraryName = 'Chintamani Library',
  }) {
    final t = topic.toLowerCase();

    if (t.contains('fee') || t.contains('due') || t.contains('fees') || t.contains('paisa') || t.contains('payment')) {
      return '*💰 FEE DUE REMINDER • $libraryName*\n\n'
          'Dear Scholar {name},\n\n'
          'This is a gentle reminder that your monthly library membership fee is pending.\n\n'
          '• *Seat:* {seat}\n'
          '• *Status:* Payment Due\n\n'
          'Kindly pay online via UPI or visit the front desk today to keep your reserved seat active.\n\n'
          '📞 *UPI / Contact:* +91 $adminNumber\n'
          '_Thank you for your cooperation!_';
    }

    if (t.contains('holiday') || t.contains('close') || t.contains('chutti') || t.contains('band') || t.contains('shut')) {
      return '*🏖️ HOLIDAY NOTICE • $libraryName*\n\n'
          'Dear Scholars & Members,\n\n'
          'Please note that the library will remain *CLOSED* on account of:\n\n'
          '• *Reason:* ${topic.trim()}\n'
          '• *Normal Timings Resume:* Next regular working day at 6:00 AM\n\n'
          'We apologize for any inconvenience caused.\n\n'
          '📞 *Helpline:* +91 $adminNumber\n'
          '_Happy Holidays & Best Wishes!_';
    }

    if (t.contains('wifi') || t.contains('internet') || t.contains('speed') || t.contains('network')) {
      return '*📶 HIGH-SPEED WI-FI UPDATE • $libraryName*\n\n'
          'Dear Scholars,\n\n'
          'We have upgraded our library Wi-Fi infrastructure for seamless learning!\n\n'
          '• High-speed fiber connectivity enabled\n'
          '• Smooth video lectures & test series streaming\n'
          '• Connect to the designated student Wi-Fi network\n\n'
          'For Wi-Fi password or connectivity help, contact admin desk.\n\n'
          '📞 *Support:* +91 $adminNumber\n'
          '_Happy Learning!_';
    }

    if (t.contains('silence') || t.contains('shanti') || t.contains('rule') || t.contains('discipline') || t.contains('awaz')) {
      return '*🤫 STRICT SILENCE & DISCIPLINE NOTICE*\n'
          '*🏛️ $libraryName*\n\n'
          'Dear Students,\n\n'
          'To ensure an optimal study atmosphere for all serious aspirants:\n\n'
          '• Please keep phones strictly on *SILENT/VIBRATE* mode\n'
          '• Phone calls must be attended *OUTSIDE* the study hall\n'
          '• Group discussions inside reading halls are prohibited\n'
          '• Keep your study desk clean before leaving\n\n'
          'Let us all maintain a peaceful environment for focused preparation.\n\n'
          '📞 *Admin Helpline:* +91 $adminNumber\n'
          '_Thank you for your cooperation!_';
    }

    // Generic custom announcement
    return polishAndFormat(topic, adminNumber: adminNumber, libraryName: libraryName);
  }
}
