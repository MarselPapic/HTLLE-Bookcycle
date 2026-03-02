<!doctype html>
<html lang="${locale.currentLanguageTag!''}">
  <body style="font-family: Arial, sans-serif; color: #1a2233; line-height: 1.45;">
    <p>Bitte fuehren Sie die erforderlichen Konto-Aktionen aus:</p>
    <p><strong>${requiredActionsText!""}</strong></p>
    <p>
      <a href="${link}" style="color: #0b7e87; font-weight: 700;">Aktionen ausfuehren</a>
    </p>
    <p style="margin-top: 24px; color: #6d7a90; font-size: 12px;">${msg("doNotReply")}</p>
  </body>
</html>
