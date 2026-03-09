package com.bookcycle.moderation.presentation.web;

import com.bookcycle.identity.application.service.IdentityApplicationService;
import com.bookcycle.identity.infrastructure.persistence.UserAccountRepository;
import com.bookcycle.marketplace.domain.service.ListingService;
import com.bookcycle.moderation.domain.service.ModerationService;
import com.bookcycle.moderation.domain.model.ReportStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Set;

/**
 * User Story: US-006 Moderation Dashboard
 */
@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminPageController {
    private final ModerationService moderationService;
    private final ListingService listingService;
    private final UserAccountRepository userAccountRepository;
    private final IdentityApplicationService identityApplicationService;

    @ModelAttribute("signedInUser")
    public String signedInUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "Not signed in";
        }
        if (authentication instanceof AnonymousAuthenticationToken) {
            return "Not signed in";
        }
        return authentication.getName();
    }

    @GetMapping
    public String index() {
        return "redirect:/admin/dashboard";
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }

    @GetMapping("/password-reset")
    public String passwordReset(@RequestParam(required = false) String email, Model model) {
        if (!model.containsAttribute("email")) {
            model.addAttribute("email", email != null ? email : "");
        }
        return "password-reset";
    }

    @PostMapping("/password-reset")
    public String requestPasswordReset(
            @RequestParam String email,
            RedirectAttributes redirectAttributes) {
        try {
            identityApplicationService.requestWebAdminPasswordReset(email);
            redirectAttributes.addFlashAttribute(
                "successMessage",
                "If the account exists, a password reset email has been sent. Check Mailpit."
            );
            return "redirect:/admin/login";
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute(
                "errorMessage",
                "Password reset request failed: " + ex.getMessage()
            );
            redirectAttributes.addFlashAttribute("email", email);
            return "redirect:/admin/password-reset";
        }
    }

    @GetMapping("/password-change")
    public String passwordChange(
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String required,
            Model model) {
        if (!model.containsAttribute("email")) {
            model.addAttribute("email", email != null ? email : "");
        }
        model.addAttribute("required", required != null);
        return "password-change";
    }

    @PostMapping("/password-change")
    public String applyPasswordChange(
            @RequestParam String email,
            @RequestParam String currentPassword,
            @RequestParam String newPassword,
            @RequestParam String confirmPassword,
            RedirectAttributes redirectAttributes) {
        if (!newPassword.equals(confirmPassword)) {
            redirectAttributes.addFlashAttribute("errorMessage", "New passwords do not match.");
            redirectAttributes.addFlashAttribute("email", email);
            return "redirect:/admin/password-change?required=1";
        }

        try {
            identityApplicationService.completeWebAdminPasswordChange(email, currentPassword, newPassword);
            redirectAttributes.addFlashAttribute(
                "successMessage",
                "Password changed successfully. Please sign in."
            );
            return "redirect:/admin/login";
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", "Password change failed: " + ex.getMessage());
            redirectAttributes.addFlashAttribute("email", email);
            return "redirect:/admin/password-change?required=1";
        }
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("currentPath", "/admin/dashboard");
        model.addAttribute("openReports", moderationService.listReports(ReportStatus.OPEN).size());
        model.addAttribute("publishedListings", listingService.countPublished());
        model.addAttribute("activeUsers", userAccountRepository.countByActiveTrue());
        return "dashboard";
    }

    @GetMapping("/reports")
    public String reports(Model model) {
        model.addAttribute("currentPath", "/admin/reports");
        model.addAttribute("reports", moderationService.listReports(null));
        return "reports";
    }

    @GetMapping("/users")
    public String users(Model model) {
        model.addAttribute("currentPath", "/admin/users");
        model.addAttribute("users", userAccountRepository.findAll());
        return "users";
    }

    @PostMapping("/users/create")
    public String createAdminUser(
            @RequestParam String email,
            @RequestParam String displayName,
            @RequestParam String temporaryPassword,
            @RequestParam(defaultValue = "MODERATOR") String role,
            RedirectAttributes redirectAttributes) {
        String normalizedRole = "ADMIN".equalsIgnoreCase(role) ? "ADMIN" : "MODERATOR";
        try {
            identityApplicationService.createWebAdminUserWithTemporaryPassword(
                email,
                displayName,
                temporaryPassword,
                Set.of(normalizedRole)
            );
            redirectAttributes.addFlashAttribute(
                "successMessage",
                "Admin user created in Keycloak. First login requires password update."
            );
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute(
                "errorMessage",
                "Could not create user: " + ex.getMessage()
            );
        }

        return "redirect:/admin/users";
    }
}
