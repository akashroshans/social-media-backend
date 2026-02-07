package com.rooks.social_media.backend.service;

import com.rooks.social_media.backend.entity.Post;
import com.rooks.social_media.backend.entity.User;
import com.rooks.social_media.backend.repository.PostRepository;
import com.rooks.social_media.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PostService {

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FileStorageService fileStorageService;

    public Post createPost(String contentText, MultipartFile image, String userEmail) throws Exception {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new Exception("User not found"));

        Post post = new Post();
        post.setContentText(contentText);
        post.setUserId(user.getId());
        post.setUserName(user.getName());
        post.setUserProfilePicture(user.getProfilePicture());
        post.setCreatedAt(LocalDateTime.now());

        if (image != null && !image.isEmpty()) {
            String fileName = fileStorageService.storeFile(image);
            post.setImageFileName(fileName);
        }

        return postRepository.save(post);
    }

    public List<Post> getAllPosts() {
        return postRepository.findAllByOrderByCreatedAtDesc();
    }

    public List<Post> getPostsByUser(String userId) {
        return postRepository.findByUserId(userId);
    }

    public void deletePost(String postId, String userEmail) throws Exception {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new Exception("Post not found"));
        
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new Exception("User not found"));

        if (!post.getUserId().equals(user.getId())) {
            throw new Exception("Unauthorized");
        }

        if (post.getImageFileName() != null) {
            fileStorageService.deleteFile(post.getImageFileName());
        }

        postRepository.deleteById(postId);
    }
}
