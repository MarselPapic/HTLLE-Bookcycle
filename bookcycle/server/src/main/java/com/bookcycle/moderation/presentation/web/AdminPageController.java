package com.bookcycle.moderation.presentation.web;

import com.bookcycle.identity.infrastructure.persistence.UserAccountRepository;
import com.bookcycle.marketplace.domain.service.ListingService;
import com.bookcycle.moderation.domain.service.ModerationService;
import com.bookcycle.moderation.domain.model.ReportStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

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

    @GetMapping
    public String index() {
        return "redirect:/admin/dashboard";
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("openReports", moderationService.listReports(ReportStatus.OPEN).size());
        model.addAttribute("publishedListings", listingService.countPublished());
        model.addAttribute("activeUsers", userAccountRepository.countByActiveTrue());
        return "dashboard";
    }

    @GetMapping("/reports")
    public String reports(Model model) {
        model.addAttribute("reports", moderationService.listReports(null));
        return "reports";
    }

    @GetMapping("/users")
    public String users(Model model) {
        model.addAttribute("users", userAccountRepository.findAll());
        return "users";
    }
}
