#include <App.hpp>
#include <Utils.hpp>
#include <Octree.hpp>
#include <string.h> // for memset


//https://antongerdelan.net/opengl/hellotriangle.html

App::App(GLFWwindow* window) : window(window), camera(&window)
{
    timestart = Get_time_ms();
}

void App::mainInput()
{
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        state = quit;
    
    float camspeed = 4.0;
    if(glfwGetKey(window, GLFW_KEY_LEFT_SHIFT) == GLFW_PRESS)
        camspeed *= 10.0;

    vec3<float> velocity(0.0);

    if(glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
    {
        velocity.x += camspeed;
    }
    if(glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
    {
        velocity.x -= camspeed;
    }
    if(glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
    {
        velocity.z -= camspeed;
    }
    if(glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
    {
        velocity.z += camspeed;
    }
    if(glfwGetKey(window, GLFW_KEY_SPACE) == GLFW_PRESS)
    {
        velocity.y += camspeed;
    }
    if(glfwGetKey(window, GLFW_KEY_LEFT_CONTROL) == GLFW_PRESS)
    {
        velocity.y -= camspeed;
    }

    camera.move(velocity);

    if(glfwGetKey(window, GLFW_KEY_KP_ADD) == GLFW_PRESS)
    {
        camera.add_FOV(-0.1);
    }

    if(glfwGetKey(window, GLFW_KEY_KP_SUBTRACT) == GLFW_PRESS)
    {
        camera.add_FOV(0.1);
    }

    if(glfwGetKey(window, GLFW_KEY_KP_SUBTRACT) == GLFW_PRESS)
    {
        // glBufferSubData(GL_SHADER_STORAGE_BUFFER, offset, size, data); //to update partially
    }
}


void App::mainloop()
{   
    /// CENTER WINDOW
    GLFWmonitor* monitor = glfwGetPrimaryMonitor();
    const GLFWvidmode* mode = glfwGetVideoMode(monitor);
    glfwSetWindowPos(window, (mode->width - 1920) / 2, (mode->height - 1080) / 2);

    /// CREATINHG QUAD TO COVER ALL THE SCREEN
    float points[] = {
    -1.0f,  1.0f,  0.0f,
    1.0f, 1.0f,  0.0f,
    -1.0f, -1.0f,  0.0f,
    
    1.0f,  -1.0f,  0.0f,
    1.0f, 1.0f,  0.0f,
    -1.0f, -1.0f,  0.0f,
    };

    GLuint vbo = 0;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, 2 * 9 * sizeof(float), points, GL_STATIC_DRAW);

    GLuint vao = 0;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);
    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);


    /// CREATING A SHADER PROGRAM
    // ShaderProgram test("shader/test.frag", "shader/test.vert", "");
    ShaderProgram test("shader/RTvox.frag", "shader/test.vert", "");

    test.activate();

    int winsize[2] = {1920, 1080};
    glUniform2iv(0, 1, winsize);

    World[1].lod_surface.color = {0xc7, 0x21, 0x8b};
    World[1].lod_surface.info  = 0;
    World[0].lod_surface.color = {0xc7, 0x21, 0x8b};
    World[0].lod_surface.info  = 0;
    for(int i = 0; i < 7; i++)
    // if(i == 0 || i == 1 || i == 4 || i == 5)
    {
        World[0].childs[i].ptr.fullpos = 1;
        World[0].childs[i].ptr.set_chunk_id(0);
    }
    for(int i = 0; i < 7; i++)
    {   
        World[1].childs[i].ptr.fullpos = 1;
        World[1].childs[i].ptr.set_chunk_id(0);
    }

    // // Generating depth test
    // for(int i = 0; i < 6; i++)
    // {   
    //     World[0].childs[i].surface.color = {0xc7, 0x21, 0x8b};
    //     World[0].childs[i].surface.info  = LEAF_LIMIT8;
    // }

    // World[0].childs[3].ptr.pos = 1;
    // World[0].childs[3].ptr.oct_chunk_pos = 0;
    // for(int i = 0; i < 7; i++)
    // {   
    //     World[1].childs[i].surface.color = {0xc5, 0x69, 0xbd};
    //     World[1].childs[i].surface.info  = LEAF_LIMIT8;
    // }

    // World[1].childs[3].ptr.pos = 2;
    // World[1].childs[3].ptr.oct_chunk_pos = 0;
    // for(int i = 0; i < 7; i++)
    // {   
    //     World[2].childs[i].surface.color = {0x2e, 0xcc, 0x71};
    //     World[2].childs[i].surface.info  = LEAF_LIMIT8;
    // }

    // World[2].childs[3].ptr.pos = 3;
    // World[2].childs[3].ptr.oct_chunk_pos = 0;
    // for(int i = 0; i < 7; i++)
    // {   
    //     World[3].childs[i].surface.color = {0xff, 0xc3, 0x00};
    //     World[3].childs[i].surface.info  = LEAF_LIMIT8;
    // }

    // World[3].childs[3].ptr.pos = 4;
    // World[3].childs[3].ptr.oct_chunk_pos = 0;
    // for(int i = 0; i < 7; i++)
    // {   
    //     World[4].childs[i].surface.color = {0xe7, 0x4c, 0x3c};
    //     World[4].childs[i].surface.info  = LEAF_LIMIT8;
    // }



    World.send_to_gpu();
    
    World[1].childs[6].ptr.fullpos = 0;
    World[1].childs[5].ptr.fullpos = 0;

    std::cout << "test : sending " << 4096*sizeof(OctNode) << " byte to an ssbo ";
    startbenchrono();
    glNamedBufferSubData(World.chunks[0].ssbo, 0, 4*sizeof(OctNode), World.chunks->nodes);
    endbenchrono();

    // glBufferSubData(GL_SHADER_STORAGE_BUFFER, offset, size, data); //to update partially

    /// MAIN LOOP
    while(state != quit)
    {
        glfwPollEvents();

        mainInput();

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        test.activate();
        glBindVertexArray(vao);

        glUniform1f(1, (Get_time_ms()-timestart)*1.0/1000.0);
        glUniform3fv(2, 1, (const GLfloat *)camera.get_position());
        glUniform3fv(3, 1, (const GLfloat *)camera.get_updated_direction());
        glUniform2fv(4, 1, (const GLfloat *)camera.get_polar_direciton());
        glUniform1f(5, camera.get_FOV());
        // std::cout << mouse[0] << "\t" << mouse[1] << "\n";

        // draw points 0-3 from the currently bound VAO with current in-use shader
        glDrawArrays(GL_TRIANGLES, 0, 6);

        glfwSwapBuffers(window);
    }
}