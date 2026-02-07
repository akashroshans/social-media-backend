package com.rooks.social_media.backend.repository;

import com.rooks.social_media.backend.entity.Post;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostRepository extends MongoRepository<Post, String> {
    List<Post> findByUserId(String userId);
    List<Post> findAllByOrderByCreatedAtDesc();
}
