package com.phishingdefense.backend.client;

import com.phishingdefense.backend.dto.auth.GoogleTokenResponse;
import com.phishingdefense.backend.dto.auth.GoogleUserInfoResponse;
import com.phishingdefense.backend.exception.GoogleLoginFailedException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

/**
 * Google OAuth2 authorization code 교환 및 사용자 정보 조회를 담당한다.
 */
@Component
public class GoogleOAuthClient {

    private final RestClient restClient;
    private final String clientId;
    private final String clientSecret;
    private final String tokenUri;
    private final String userInfoUri;
    private final String redirectUri;

    public GoogleOAuthClient(
            @Value("${oauth2.google.client-id}") String clientId,
            @Value("${oauth2.google.client-secret}") String clientSecret,
            @Value("${oauth2.google.token-uri}") String tokenUri,
            @Value("${oauth2.google.user-info-uri}") String userInfoUri,
            @Value("${oauth2.google.redirect-uri}") String redirectUri
    ) {
        this.restClient = RestClient.create();
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.tokenUri = tokenUri;
        this.userInfoUri = userInfoUri;
        this.redirectUri = redirectUri;
    }

    public GoogleTokenResponse exchangeCode(String code) {
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("code", code);
        form.add("client_id", clientId);
        form.add("client_secret", clientSecret);
        form.add("redirect_uri", redirectUri);
        form.add("grant_type", "authorization_code");

        try {
            return restClient.post()
                    .uri(tokenUri)
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(form)
                    .retrieve()
                    .body(GoogleTokenResponse.class);
        } catch (RestClientException e) {
            throw new GoogleLoginFailedException("Google 인증 코드 교환에 실패했습니다.", e);
        }
    }

    public GoogleUserInfoResponse fetchUserInfo(String accessToken) {
        try {
            return restClient.get()
                    .uri(userInfoUri)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken)
                    .retrieve()
                    .body(GoogleUserInfoResponse.class);
        } catch (RestClientException e) {
            throw new GoogleLoginFailedException("Google 사용자 정보를 가져오지 못했습니다.", e);
        }
    }
}
