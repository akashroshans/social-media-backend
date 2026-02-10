package com.rooks.social_media.backend.service;

import com.rooks.social_media.backend.entity.User;
import com.rooks.social_media.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;

@Service
public class UserService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private FileStorageService fileStorageService;

    public User registerUser(User user) throws Exception {
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new Exception("Email already exists");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    public User findByEmail(String email) throws Exception {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new Exception("User not found"));
    }

    public boolean verifyCredentials(String email, String rawPassword) {
        try {
            User user = findByEmail(email);
            return passwordEncoder.matches(rawPassword, user.getPassword());
        } catch (Exception e) {
            return false;
        }
    }

    public User updateProfile(String userId, String name, String bio, MultipartFile profilePicture) throws Exception {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new Exception("User not found"));
        
        if (name != null && !name.trim().isEmpty()) {
            user.setName(name);
        }
        
        if (bio != null) {
            user.setBio(bio);
        }
        
        if (profilePicture != null && !profilePicture.isEmpty()) {
            if (user.getProfilePicture() != null) {
                fileStorageService.deleteFile(user.getProfilePicture());
            }
            String fileName = fileStorageService.storeFile(profilePicture);
            user.setProfilePicture(fileName);
        }
        
        return userRepository.save(user);
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                new ArrayList<>()
        );
    }
}
