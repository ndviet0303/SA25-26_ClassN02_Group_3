package com.nozie.notificationservice.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * EmailService
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;

    @Value("${spring.mail.username:noreply@nozie.com}")
    private String fromEmail;

    @Value("${app.name:Nozie}")
    private String appName;

    /**
     * Gửi email chào mừng user mới đăng ký
     */
    public void sendWelcomeEmail(String toEmail, String fullName) {
        log.info("Sending welcome email to: {}", toEmail);

        Context context = new Context();
        context.setVariable("fullName", fullName);
        context.setVariable("appName", appName);

        String htmlContent = templateEngine.process("email/welcome", context);
        sendHtmlEmail(toEmail, "Welcome to " + appName + "!", htmlContent);
    }

    /**
     * Gửi email xác nhận kích hoạt gói Premium
     */
    public void sendSubscriptionActivatedEmail(String toEmail, String fullName, String planName, LocalDate endDate) {
        log.info("Sending subscription activated email to: {}", toEmail);

        Context context = new Context();
        context.setVariable("fullName", fullName);
        context.setVariable("planName", planName);
        context.setVariable("endDate", endDate.format(DateTimeFormatter.ofPattern("MM/dd/yyyy")));
        context.setVariable("appName", appName);

        String htmlContent = templateEngine.process("email/subscription-activated", context);
        sendHtmlEmail(toEmail, "Your " + planName + " plan is active!", htmlContent);
    }

    /**
     * Gửi email nhắc nhở gia hạn gói Premium
     */
    public void sendSubscriptionExpiringEmail(String toEmail, String fullName, String planName, int daysLeft) {
        log.info("Sending subscription expiring email to: {}", toEmail);

        Context context = new Context();
        context.setVariable("fullName", fullName);
        context.setVariable("planName", planName);
        context.setVariable("daysLeft", daysLeft);
        context.setVariable("appName", appName);

        String htmlContent = templateEngine.process("email/subscription-expiring", context);
        sendHtmlEmail(toEmail, "Your " + planName + " plan is expiring soon!", htmlContent);
    }

    /**
     * Gửi email HTML
     */
    private void sendHtmlEmail(String to, String subject, String htmlContent) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            log.info("Email sent successfully to: {}", to);
        } catch (MessagingException e) {
            log.error("Failed to send email to {}: {}", to, e.getMessage());
            // Don't throw exception - email failure shouldn't break the flow
        }
    }
}
