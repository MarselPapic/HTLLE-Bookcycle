<!doctype html>
<html lang="${locale.currentLanguageTag!''}">
  <body style="font-family: Arial, sans-serif; color: #1a2233; line-height: 1.45;">
    <p>${msg("emailVerificationBodyHtml", link)?no_esc}</p>
    <p style="margin-top: 24px; color: #6d7a90; font-size: 12px;">${msg("doNotReply")}</p>
  </body>
</html>
