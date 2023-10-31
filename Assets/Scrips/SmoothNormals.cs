using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class SmoothNormals : MonoBehaviour
{
    private void Awake()
    {
        // ��ȡģ�͵���������
        Mesh mesh = GetComponent<SkinnedMeshRenderer>().sharedMesh;

        // ʹ�� LINQ ��ѯ�����㰴��λ�÷��飬�Ա��������ƽ������
        IEnumerable<IEnumerable<KeyValuePair<Vector3, int>>>
            groups = mesh.vertices.Select(
                (vertex, index) => new KeyValuePair<Vector3, int>(vertex, index)).GroupBy(pair => pair.Key);

        // ��ȡԭʼ��������
        Vector3[] normals = mesh.normals;

        // ����һ���µ������Դ洢ƽ�����ߣ�ʹ��Vector4����mesh.tangents����
        Vector4[] smoothNormals = normals.Select((normal, index) => new Vector4(normal.x, normal.y, normal.z)).ToArray();

        // ����ÿ���������
        foreach (var group in groups)
        {
            // ������������һ�Σ�����Ҫƽ������
            if (group.Count() == 1)
            {
                continue;
            }

            // ��ʼ��ƽ����������
            Vector3 smoothNormal = Vector3.zero;

            // �������ڵĶ��㣬�ۼ��䷨��
            foreach (var pair in group)
                smoothNormal += normals[pair.Value];

            // ��һ��ƽ����������
            smoothNormal.Normalize();

            // �������ƽ�����߸���ÿ�����ڵĶ���
            foreach (var pair in group)
                smoothNormals[pair.Value] = new Vector4(smoothNormal.x, smoothNormal.y, smoothNormal.z);
        }

        // �������ƽ����������Ӧ����ģ�͵��������ݣ�tangents��
        mesh.tangents = smoothNormals;
        Debug.Log("--------------------------------------");
    }
}

/*using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class SmoothNormals : MonoBehaviour
{
    private void Awake()
    {
        Mesh mesh = GetComponent<SkinnedMeshRenderer>().sharedMesh;
        Vector3[] vertices = mesh.vertices;
        Vector3[] normals = mesh.normals;
        Vector4[] tangents = mesh.tangents;

        Dictionary<Vector3, List<int>> vertexToIndex = new Dictionary<Vector3, List<int>>();
        Vector3[] smoothNormals = new Vector3[vertices.Length];

        // ��ʼ��ƽ������
        for (int i = 0; i < smoothNormals.Length; i++)
        {
            smoothNormals[i] = Vector3.zero;
        }

        // ����ÿ�����㣬�����ǰ���λ�÷���
        for (int i = 0; i < vertices.Length; i++)
        {
            Vector3 vertex = vertices[i];
            if (!vertexToIndex.ContainsKey(vertex))
            {
                vertexToIndex[vertex] = new List<int>();
            }
            vertexToIndex[vertex].Add(i);
        }

        // ����ÿ���������
        foreach (var group in vertexToIndex.Values)
        {
            if (group.Count == 1)
            {
                continue; // ���������һ�Σ�����ƽ������
            }

            // ����ƽ������
            Vector3 averageNormal = Vector3.zero;
            for (int i = 0; i < group.Count; i++)
            {
                averageNormal += normals[group[i]];
            }
            averageNormal /= group.Count;

            // Ӧ��ƽ�����ߵ�ÿ������
            for (int i = 0; i < group.Count; i++)
            {
                smoothNormals[group[i]] = averageNormal;
            }
        }

        // ����ģ�͵ķ��ߺ���������
        mesh.normals = smoothNormals;
        mesh.RecalculateNormals();
        mesh.tangents = tangents;
        Debug.Log("--------------------------------------");
    }
}*/


