package com.devsecops;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.ResponseEntity;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.client.RestTemplate;

@WebMvcTest(NumericController.class)
@ExtendWith(MockitoExtension.class)
class NumericControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private RestTemplate restTemplate;

    @InjectMocks
    private NumericController numericController;

    private static final String BASE_URL = "http://node-service:5000/plusone";

    @BeforeEach
    void setUp() {
        numericController = new NumericController(restTemplate);
    }

    @Test
    void testWelcome() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(content().string("Kubernetes DevSecOps"));
    }

    @Test
    void testCompareToFifty() throws Exception {
        mockMvc.perform(get("/compare/60"))
                .andExpect(status().isOk())
                .andExpect(content().string("Greater than 50"));

        mockMvc.perform(get("/compare/40"))
                .andExpect(status().isOk())
                .andExpect(content().string("Smaller than or equal to 50"));
    }

    @Test
    void testIncrement() throws Exception {
        when(restTemplate.getForEntity(BASE_URL + "/10", String.class))
                .thenReturn(ResponseEntity.ok("11"));

        mockMvc.perform(get("/increment/10"))
                .andExpect(status().isOk())
                .andExpect(content().string("11"));
    }
}