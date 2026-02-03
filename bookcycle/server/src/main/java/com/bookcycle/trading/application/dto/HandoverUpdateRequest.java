package com.bookcycle.trading.application.dto;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class HandoverUpdateRequest {
    private LocalDateTime meetingTime;
    private String meetingPlace;
    private String conditionNotes;
}
