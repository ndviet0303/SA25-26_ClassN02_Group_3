package com.nozie.paymentservice.application.service;

import com.nozie.common.dto.ApiResponse;
import com.nozie.paymentservice.api.dto.PaymentRequest;
import com.nozie.paymentservice.api.dto.PaymentResponse;
import com.nozie.paymentservice.domain.model.Transaction;
import com.nozie.paymentservice.domain.repository.TransactionRepository;
import com.nozie.paymentservice.infrastructure.client.CustomerClient;
import com.nozie.paymentservice.infrastructure.client.MovieClient;
import com.nozie.paymentservice.infrastructure.client.dto.CustomerDTO;
import com.nozie.paymentservice.infrastructure.client.dto.MovieDTO;
import com.nozie.paymentservice.infrastructure.messaging.PaymentEventProducer;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PaymentApplicationServiceTest {

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private MovieClient movieClient;

    @Mock
    private CustomerClient customerClient;

    @Mock
    private PaymentEventProducer eventProducer;

    @InjectMocks
    private PaymentApplicationService paymentApplicationService;

    private PaymentRequest paymentRequest;
    private MovieDTO movieDTO;
    private CustomerDTO customerDTO;

    @BeforeEach
    void setUp() {
        paymentRequest = new PaymentRequest();
        paymentRequest.setCustomerId(1L);
        paymentRequest.setMovieId(1L);
        paymentRequest.setAmount(new BigDecimal("10.00"));
        paymentRequest.setCurrency("usd");

        movieDTO = new MovieDTO();
        movieDTO.setId(1L);
        movieDTO.setTitle("Test Movie");
        movieDTO.setPrice(new BigDecimal("10.00"));

        customerDTO = new CustomerDTO();
        customerDTO.setId(1L);
        customerDTO.setFirstName("John");
        customerDTO.setLastName("Doe");
    }

    @Test
    void createPayment_Success() {
        // Arrange
        when(movieClient.getMovieById(1L)).thenReturn(ApiResponse.success(movieDTO));
        when(customerClient.getCustomerById(1L)).thenReturn(ApiResponse.success(customerDTO));

        Transaction mockTransaction = Transaction.create(1L, 1L, new BigDecimal("10.00"), "usd");
        mockTransaction.setId(100L);
        when(transactionRepository.save(any(Transaction.class))).thenReturn(mockTransaction);

        // Act
        PaymentResponse response = paymentApplicationService.createPayment(paymentRequest);

        // Assert
        assertNotNull(response);
        assertEquals(100L, response.getTransactionId());
        verify(movieClient).getMovieById(1L);
        verify(customerClient).getCustomerById(1L);
        verify(transactionRepository).save(any(Transaction.class));
    }

    @Test
    void createPayment_MovieNotFound() {
        // Arrange
        when(movieClient.getMovieById(1L)).thenReturn(ApiResponse.error("Not Found"));

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> paymentApplicationService.createPayment(paymentRequest));

        assertTrue(exception.getMessage().contains("Movie not found"));
        verify(movieClient).getMovieById(1L);
        verifyNoInteractions(customerClient, transactionRepository);
    }

    @Test
    void createPayment_CustomerNotFound() {
        // Arrange
        when(movieClient.getMovieById(1L)).thenReturn(ApiResponse.success(movieDTO));
        when(customerClient.getCustomerById(1L)).thenReturn(ApiResponse.error("Not Found"));

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> paymentApplicationService.createPayment(paymentRequest));

        assertTrue(exception.getMessage().contains("Customer not found"));
        verify(customerClient).getCustomerById(1L);
        verifyNoInteractions(transactionRepository);
    }

    @Test
    void createPayment_MovieClientError() {
        // Arrange
        when(movieClient.getMovieById(1L)).thenThrow(new RuntimeException("Connection Failed"));

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> paymentApplicationService.createPayment(paymentRequest));

        assertTrue(exception.getMessage().contains("Could not validate movie"));
        verifyNoInteractions(customerClient, transactionRepository);
    }
}
