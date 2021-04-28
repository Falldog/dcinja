
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
        if (!fs.good()) {
            std::cout << "can't find the file: " << srcPath << std::endl;
            exit(1);
        }
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
            ("e,envs", "define environment parameters, read system env when not assigned value, ex: `-e NAME=FOO -e NUM=1 -e MY_ENV`", cxxopts::value<std::vector<std::string>>())
            ("force-system-envs", "force to use system envs as final value", cxxopts::value<bool>()->default_value("false"))
            ("j,json", "define json content, ex: `-j {\"NAME\": \"FOO\"} -j {\"PHONE\": \"123\"}`", cxxopts::value<std::vector<std::string>>())
            ("f,json-file", "load json content from file, ex: `-f p1.json -f p2.json`", cxxopts::value<std::vector<std::string>>())
            ("v,verbose", "verbose mode", cxxopts::value<bool>()->default_value("false"))
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
        if (chdir(cwd.c_str()) != 0) {
            std::cout << "cwd fail, please make sure your dir path exists" << std::endl;
            exit(1);
        }
    }

    // 1. prepare json data & extra envs
    //    priority: envs(-e) >> json(-j) >> json-file(-f)
    if (result.count("json-file")) {
        auto& json_files = result["json-file"].as<std::vector<std::string>>();
        for (size_t i=0 ; i<json_files.size() ; ++i) {
            std::string json_content;
            read_source(json_files[i], json_content);
            data.merge_patch(
                json::parse(json_content.begin(), json_content.end())
            );
        }
    }
    if (result.count("json")) {
        auto& jsons = result["json"].as<std::vector<std::string>>();
        for (size_t i=0 ; i<jsons.size() ; ++i) {
            data.merge_patch(
                json::parse(jsons[i])
            );
        }
    }
    if (result.count("envs")) {
        auto& envs = result["envs"].as<std::vector<std::string>>();
        for (size_t i=0 ; i<envs.size() ; ++i) {
            auto idx = envs[i].find_first_of("=");
            if (idx == std::string::npos) {
                char * _env = std::getenv(envs[i].c_str());
                if (_env) {
                    std::string value = _env;
                    data[envs[i]] = value;
                }
            }
            else {
                std::string key = envs[i].substr(0, idx);
                std::string value = envs[i].substr(idx+1);
                data[key] = value;
            }
        }
    }
    if (result.count("force-system-envs")) {
        for (json::iterator it = data.begin(); it != data.end(); ++it) {
            char * _env = std::getenv(it.key().c_str());
            if (_env) {
                std::string value = _env;
                data[it.key()] = value;
            }
        }
    }
    if (result.count("verbose")) {
        std::cerr << "<<< JSON content: >>>" << std::endl;
        std::cerr << data.dump(4) << std::endl;
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
