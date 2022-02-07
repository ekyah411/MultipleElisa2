using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
public class SceneLoadManager2 : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField] private string sceneName;
    [SerializeField] private string sceneName2;
    private float delayDuration1 = 2f;
    private float delayDuration2 = 5f;
    void Start()
    {
        // wait 2 seconds, then load the other scene additively
        StartCoroutine(LoadSceneDelay());
    }
    IEnumerator LoadSceneDelay()
    {
        yield return new WaitForSeconds(delayDuration1);
        SceneManager.LoadScene(sceneName, LoadSceneMode.Additive);
        StartCoroutine(LoadNextSceneDelay());
    }

    IEnumerator LoadNextSceneDelay()
    {
        yield return new WaitForSeconds(delayDuration2);
        SceneManager.UnloadSceneAsync(sceneName);
        SceneManager.LoadScene(sceneName2, LoadSceneMode.Additive);
    }
}
