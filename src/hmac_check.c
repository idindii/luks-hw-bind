/*
 * HMAC Verification Utility
 *
 * HMAC = HMAC_SHA256(CPU_SERIAL, SECRET_KEY)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define HMAC_FILE           "/root/luks/expected_hmac"           //This is the path where the expected (stored) HMAC is saved.
#define HMAC_SECRET_KEY     "A9f3KxQ2LmP8Z0W1eR7S5T4C6D8BHYUJ!"   //It is a fixed secret key used to compute the HMAC.

#define EXIT_SUCCESS_CODE 0
#define EXIT_FAILURE_CODE 1

#define SERIAL_BUFFER_SIZE    128U
#define LINE_BUFFER_SIZE      256U
#define HMAC_BUFFER_SIZE      256U
#define HMAC_COMMAND_SIZE     512U

/**
  * @brief  Check if a file exists and can be opened for reading.
  * @param  path: Path to the file to be checked.
  * @retval int
  *         - true: File exists and is accessible
  *         - false: File does not exist or cannot be opened
  */
static bool file_exists(const char *path) {
    FILE *f = fopen(path, "r");
    if (f) { 
        fclose(f); 
        return true; 
    }
    return false;
}

/**
  * @brief  Read CPU serial number from /proc/cpuinfo.
  * @param  buf: Pointer to buffer where the serial string will be stored.
  * @param  sz:  Size of the buffer in bytes.
  * @retval None
  *
  * @note   The function searches for a line starting with "Serial" in
  *         /proc/cpuinfo, extracts the serial value, removes whitespace
  *         and newline characters, and stores it in the provided buffer.
  * @note   If the file cannot be opened or the serial is not found,
  *         the function prints an error message and terminates the program.
  */
static void read_cpu_serial(char *buf, size_t sz) 
{
    FILE *f = fopen("/proc/cpuinfo", "r");
    if (!f) {
        perror("fopen cpuinfo");
        exit(EXIT_FAILURE_CODE);
    }

    char line[LINE_BUFFER_SIZE];
    while (fgets(line, sizeof(line), f)) {
        if (strncmp(line, "Serial", 6) == 0) {
            char *p = strchr(line, ':');
            if (p) {
                p++;
                while (*p == ' ' || *p == '\t') p++;
                strncpy(buf, p, sz - 1);
                buf[sz - 1] = 0;
                buf[strcspn(buf, "\r\n")] = 0;
                fclose(f);
                return;
            }
        }
    }

    fclose(f);
    fprintf(stderr, "Serial not found\n");
    exit(EXIT_FAILURE_CODE);
}

/**
  * @brief  Compute HMAC-SHA256 of the given serial using a secret key.
  * @param  serial: Input string (CPU serial number).
  * @param  out:    Output buffer where the HMAC string will be stored.
  * @param  outsz:  Size of the output buffer in bytes.
  * @retval None
  *
  * @note   This function uses the OpenSSL command-line tool to compute:
  *         HMAC_SHA256(serial, SECRET).
  * @note   The resulting hash is returned as a hexadecimal string
  *         without newline characters.
  * @note   If command execution or output reading fails, the function
  *         prints an error message and terminates the program.
  */
static void compute_hmac(const char *serial, char *out, size_t outsz) 
{
    char cmd[HMAC_COMMAND_SIZE];
    snprintf(cmd, sizeof(cmd),
             "echo -n \"%s\" | openssl dgst -sha256 -hmac \"%s\" | awk '{print $2}'",
             serial, HMAC_SECRET_KEY);

    FILE *p = popen(cmd, "r");
    if (!p) {
        perror("popen");
        exit(EXIT_FAILURE_CODE);
    }

    if (!fgets(out, outsz, p)) {
        fprintf(stderr, "Failed to read HMAC\n");
        pclose(p);
        exit(EXIT_FAILURE_CODE);
    }

    out[strcspn(out, "\r\n")] = 0;
    pclose(p);
}

/**
  * @brief  Application entry point.
  * @retval int
  *         - 0: HMAC matches the stored value or is stored for the first time
  *         - 1: HMAC mismatch or file operation error
  *
  * @note   The application performs the following steps:
  *         1. Creates the /root/luks directory if it does not exist.
  *         2. Reads the CPU serial number.
  *         3. Computes the HMAC-SHA256 of the serial using a secret key.
  *         4. If the HMAC file does not exist (first boot), it stores the HMAC.
  *         5. If the HMAC file exists, it compares the stored HMAC with the
  *            newly computed one.
  *         6. Returns 0 if they match, otherwise returns 1.
  */
int main(int argc, char *argv[]) {
    system("mkdir -p /root/luks");

    char serial[SERIAL_BUFFER_SIZE];
    char hmac[HMAC_BUFFER_SIZE];

    read_cpu_serial(serial, sizeof(serial));
    compute_hmac(serial, hmac, sizeof(hmac));

    if (argc > 1 && strcmp(argv[1], "--print-hmac") == 0) {
        printf("%s\n", hmac);
        return 0;
    }

    if (!file_exists(HMAC_FILE)) {
        FILE *f = fopen(HMAC_FILE, "w");
        if (!f) 
        {
            perror("fopen HMAC_FILE");
            return 1;
        }
        fprintf(f, "%s\n", hmac);
        fclose(f);
        return 0;
    }

    char stored[HMAC_BUFFER_SIZE];
    FILE *f = fopen(HMAC_FILE, "r");
    if (!f) {
        perror("fopen stored HMAC");
        return 1;
    }

    if (!fgets(stored, sizeof(stored), f)) {
        fclose(f);
        return 1;
    }
    fclose(f);

    stored[strcspn(stored, "\r\n")] = 0;

    return strcmp(hmac, stored) == 0 ? 0 : 1;
}