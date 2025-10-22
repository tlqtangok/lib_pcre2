#include "rex.h"
#include <iostream>

int main()
{
    std::cout << "PCRE2 Version: " << rex_match::version() << std::endl << std::endl;
    
    {
        std::cout << "=== Test 1: Basic Match ===" << std::endl;
        rex text("Hello 123 World");
        
        if (text % m(R"(\d+)"))
        {
            std::cout << "Match found!" << std::endl;
        }
        else
        {
            std::cout << "No match" << std::endl; 
        }
    }
    
    {
        std::cout << "\n=== Test 2: Capture Groups ===" << std::endl;
        rex email("user@example.com");
        rex_match matcher = m(R"((\w+)@(\w+\.\w+))");
        
        if (email % matcher)
        {
            std::cout << "Full match: " << matcher[0] << std::endl;
            std::cout << "Username: " << matcher[1] << std::endl;
            std::cout << "Domain: " << matcher[2] << std::endl;
        }
    }
    
    {
        std::cout << "\n=== Test 3: Case Insensitive ===" << std::endl;
        rex text("Hello World");
        
        if (text % m(R"(hello)", "i"))
        {
            std::cout << "Case insensitive match works!" << std::endl;
        }
    }
    
    {
        std::cout << "\n=== Test 4: Simple Substitution ===" << std::endl;
        rex text("abc123abc456");
        
        std::cout << "Before: " << text.str() << std::endl;
        text % s(R"(abc)", "XYZ");
        std::cout << "After:  " << text.str() << std::endl;
    }
    
    {
        std::cout << "\n=== Test 5: Global Substitution ===" << std::endl;
        rex text("abc123abc456abc");
        
        std::cout << "Before: " << text.str() << std::endl;
        text % s(R"(abc)", "XYZ", "g");
        std::cout << "After:  " << text.str() << std::endl;
    }
    
    {
        std::cout << "\n=== Test 6: Multiple Operations ===" << std::endl;
        rex text("The price is $100");
        
        if (text % m(R"(\$(\d+))"))
        {
            auto matcher = m(R"(\$(\d+))");
            // matcher(text.str());
            text % matcher;

            std::cout << "Found price: $" << matcher[1] << std::endl;
        }
        
        text % s(R"(\$\d+)", "$200");
        std::cout << "Updated: " << text.str() << std::endl;
    }
    
    {
        std::cout << "\n=== Test 7: Phone Formatting ===" << std::endl;
        rex phone("1234567890");
        
        std::cout << "Before: " << phone.str() << std::endl;
        phone % s(R"((\d{3})(\d{3})(\d{4}))", R"(($1) $2-$3)");
        std::cout << "After:  " << phone.str() << std::endl;
    }
    
    std::cout << "\n=== All tests completed ===" << std::endl;
    
    return 0;
}
