
#include <istream>
#include <ostream>
#include <iostream>
#include <iterator>
#include <fstream>
#include <unistd.h>

#include <inja/inja.hpp>
#include <cxxopts/cxxopts.hpp>
#include <nlohmann/json.hpp>

using namespace inja;
using json = nlohmann::json;


bool read_source(std::string srcPath, std::string& content) {
    if (srcPath == "") {
        std::istream_iterator<char> it(std::cin >> std::noskipws);
        std::istream_iterator<char> end;
        content.assign(it, end);
    } else {
        std::ifstream fs(srcPath);
        fs.seekg(0, std::ios::end);
        size_t size = fs.tellg();
        std::string buffer(size, ' ');
        fs.seekg(0);
        fs.read(&buffer[0], size); 
        content = buffer;
    }
    return true;
}


cxxopts::ParseResult parse(int argc, char* argv[]) {
    try {
        cxxopts::Options options(argv[0], "dcinja");
        options
            .positional_help("[optional args]")
            .show_positional_help();

        options
            .allow_unrecognised_options()
            .add_options()
            ("h,help", "print help")
            ("w,cwd", "change current working dir", cxxopts::value<std::string>())
            ("s,src", "source template file path", cxxopts::value<std::string>())
            ("d,dest", "dest template file path", cxxopts::value<std::string>())
            // ("e,defines", "define parameters, ex: `-e NAME=FOO -d VALUE=BAR`", cxxopts::value<std::vector<std::string>>())
            ("j,json", "define json content, ex: `-j {\"NAME\": \"FOO\"}`", cxxopts::value<std::string>())
            ("v,verbose", "verbose mode", cxxopts::value<bool>()->default_value("true"))
        ;

        auto result = options.parse(argc, argv);

        if (result.count("help")) {
            std::cout << options.help({""}) << std::endl;
            exit(0);
        }
        return result;

    } catch (const cxxopts::OptionException& e) {
        std::cout << "error parsing options: " << e.what() << std::endl;
        exit(1);
    }
}


int execute(cxxopts::ParseResult& result) {
    json data;
    std::string content;

    // 0. change current working dir
    if (result.count("cwd")) {
        auto cwd = result["cwd"].as<std::string>();
        chdir(cwd.c_str());
    }

    // 1. prepare json data
    if (result.count("json")) {
        data = json::parse(result["json"].as<std::string>());
    }

    // 2. read source content
    if (result.count("src")) {
        auto src = result["src"].as<std::string>();
        read_source(src, content);
    } else {
        read_source("", content);
    }

    // 3. render output
    if (result.count("dest")) {
        auto dest = result["dest"].as<std::string>();
        std::ofstream ofs;
        ofs.open(dest, std::ofstream::out | std::ofstream::trunc);
        render_to(ofs, content, data);
        ofs.close();
    } else {
        render_to(std::cout, content, data);
    }
    return 0;
}


int main(int argc, char* argv[]) {
  auto result = parse(argc, argv);
  return execute(result);
}
